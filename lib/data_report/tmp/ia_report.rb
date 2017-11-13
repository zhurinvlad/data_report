require 'csv'
require 'axlsx'

class IaReport < ActiveRecord::Base
  belongs_to :user, foreign_key: 'ia_user_id'
  enum status: [:waiting, :processing, :processed, :error]
  enum format: [:html, :json, :pdf, :xlsx, :csv]

  validate { |_ia_report| validate_params }

  before_destroy :destroy_file

  default_scope { where(deleted: false).order(created_at: :desc) }
  scope :for_user, -> (user) { where(user: user) }

  attr_accessor :title
  attr_accessor :columns
  attr_accessor :data
  attr_accessor :params

  def initialize(*args)
    super
    init_params
  end

  def init_params
    return if @inited
    @inited = true
    @params = begin
                JSON.parse(report_params)
              rescue
                {}
              end
    @missing_fields = []
    @cmd = ''
    @required_params = []
  end

  def destroy_file
    return true if report_filename.blank?
    full_filename = report_dir.join(report_filename)
    begin
      File.unlink(full_filename) if File.exist?(full_filename)
      true
    rescue
      logger.error("Не удалось удалить отчет #{full_filename}")
      false
    end
  end

  def self.clean_old_reports!
    old_reports = IaReport.unscoped.where('created_at <= :now', now: Time.zone.now - 5.days)
    old_reports.destroy_all
  end

  # генерирует новый отчет из БД и сохраняет его в файл
  def generate_report
    init_params
    update_attributes(status: :processing)
    @data = generate.to_json
    save_report!
  rescue Exception => error
    update_attributes(status: :error)
    bc = ActiveSupport::BacktraceCleaner.new
    bc.add_filter   { |line| line.gsub(Rails.root.to_s + File::SEPARATOR, "\t") } # strip the Rails.root prefix
    bc.add_silencer { |line| line =~ /mongrel|rubygems/ } # skip any lines from mongrel or rubygems
    # perform the cleanup
    logger.error("CRITICAL ERROR!!!\n#{error.message}\n#{bc.clean(error.backtrace).join("\n")}")
  end

  def generate
    fail NotImplementedError if @cmd.blank?
    select_all
  end

  def validate_params
    init_params unless @inited
    @missing_fields = @required_params.select do |param_name|
      @params[param_name].nil?
    end
    res = @missing_fields.empty?
    errors.add(:params, "Нет обязательных параметров для отчета: " \
                        "#{@missing_fields.join(', ')}"
              ) unless res
    res
  end

  def get_new_report(begin_date, end_date, mc_id, processing_id, format)
    method_name = "to_#{format}".to_sym
    fail NotImplementedError unless respond_to? method_name
    mcs = get_mcp_ids(mc_id)
    return '' if mcs.empty?
    filename = "report-#{id}.zip"
    temp_file = Tempfile.new(filename)
    Zip.unicode_names = true
    begin
      Zip::OutputStream.open(temp_file) { |zos| }
      Zip::File.open(temp_file.path, Zip::File::CREATE) do |zip|
        mcs.each do |mc|
          self.class.generate_for_mc_by_date(mc.id, Date.today.strftime('%Y-%m-%d')) if Date.new(*end_date.split('-').map(&:to_i)) >= Date.today
          title = "Отчет по #{mc.merchant.name.tr('/', '-')} - #{mc.masked_key.PaymentKey} с #{@params['start_period']} до #{@params['end_period']}"
          data = get_reports_data(begin_date, end_date, mc.id)
          unless processing_id == 'all'
            processing = get_processing_name_for_filter(processing_id)
            data.reject! do |record|
              record['Банк'] != processing
            end
          end
          zip.get_output_stream('Report from ' \
            "#{@params['start_period']} to " \
            "#{@params['end_period']}/" \
            "#{mc.merchant.name.tr('/', '-')} - #{mc.masked_key.PaymentKey}.#{format}") do |os|
            os.write send(method_name, {'data' => data, 'title' => title})
          end
        end
      end
      zip_data = File.read(temp_file.path)
    ensure
      temp_file.close
      temp_file.unlink
    end
    zip_data
  end

  def get_mcp_ids(mc_id)
    user_mcs = user.allowed_merchant_contracts
    if mc_id == 'all'
      user_mcs
    else
      user_mcs.where(id: mc_id)
    end
  end

  def get_processing_name_for_filter(processing_id)
    processing = Processing.find(processing_id).Name
    case processing
      when 'RussianStandardBank'
        'Банк Русский Стандарт'
      when 'BM'
        'Банк Москвы'
      when 'PSB'
        'Промсвязьбанк'
      when 'AlfaBank'
        'Альфа-Банк'
      when 'SurgutNefteGasBank'
        'Сургутнефтегазбанк'
      when 'LatvijasPastaBanka'
        ' Latvijas Pasta Banka'
      else processing
    end
  end

  def get_reports_data(begin_period, end_period, mc_id, can_restart=true)
    begin_date = Date.new(*begin_period.split('-').map(&:to_i))
    end_date   = Date.new(*end_period.split('-').map(&:to_i))
    result = []
    (begin_date..end_date).each do |date|
      str_date = date.strftime('%Y-%m-%d')
      result.concat load_report_data(str_date, mc_id)
    end
    return result if errors[:report_file].empty?
    unless can_restart
      errors.delete :report_file
      update_attributes(status: :error)
      return nil
    end
    errors[:report_file].each do |report_error|
      error_date = report_error[0]
      error_mc_id = report_error[1]
      self.class.generate_for_mc_by_date(error_mc_id, error_date)
    end
    errors.delete :report_file
    get_reports_data(begin_period, end_period, mc_id, false)
  end

  def load_report_data(report_date, mc_id)
    filename = self.class.report_by_date_dir(report_date).join("#{mc_id}.json")
    file = File.open(filename, 'rb')
    JSON.parse(file.read)
  rescue
    logger.error("Ошибка чтения файла отчетов #{filename}")
    errors[:report_file] << [report_date, mc_id]
    return []
  ensure
    file.close unless file.nil?
  end

  def get_report(format)
    init_params
    load_report! if @data.nil?
    @data[format]
  end

  def to_format(_format)
    load_report! if @data.nil?
  end

  def to_json(opts)
    opts.to_json
  end

  def render_anywhere(partial, assigns)
    av = ActionView::Base.new(ActionController::Base.view_paths, assigns, ActionController::Base.new)
    av.config = Rails.application.config.action_controller
    av.class_eval do
      include Rails.application.routes.url_helpers
      include ApplicationHelper
      def protect_against_forgery?
        false
      end
    end
    av.render template: partial
  end

  def self.params2string
    @required_params.map { |param_name| "'#{@params[param_name]}'" }.join(', ')
  end

  def self.select_all
    self.use_slave_db do
      sql_cmd = "call #{@cmd + '(' + params2string + ');'}"
      db = ActiveRecord::Base.connection

      rows = db.select_all(sql_cmd)
      db.reconnect!
      rows
    end
  end

  def self.save_report_by_day
    r_dir = report_by_date_dir(@params['start_period'])
    filename = "#{@params['mc_id']}.json"
    full_filename = r_dir.join(filename)
    begin
      file = File.open(full_filename, 'wb')
      file.write(@report_data)
    rescue Exception => e
      logger.error("Ошибка сохранения файла '#{full_filename}': #{e}")
    ensure
      file.close unless file.nil?
    end
  end

  def save_report!
    r_dir = report_dir
    filename = self[:report_filename]
    loop do
      filename = SecureRandom.uuid + '.json'
      break unless r_dir.join(filename).exist?
    end if filename.blank?
    begin
      file = File.open(r_dir.join(filename), 'wb')
      file.write(@data)
    rescue Exception => e
      logger.error("Ошибка сохранения файла #{e}")
      update_attributes(status: :error)
      raise e
    else
      update_attributes(status: :processed, report_filename: filename)
    ensure
      file.close unless file.nil?
    end
  end

  def load_report!
    file = File.open(report_dir.join(self[:report_filename]), 'rb')
    @data = JSON.parse(file.read)
  rescue IOError => e
    logger.error("Ошибка чтения файла отчетов #{self[:report_filename]}")
    raise e
  ensure
    file.close unless file.nil?
  end

  def report_dir
    dir = Rails.root.join('tmp', 'reports')
    dir.mkpath unless dir.exist?
    dir
  end

  def self.report_by_date_dir(date)
    dir = Rails.root.join('tmp', 'reports', self.name, date)
    dir.mkpath unless dir.exist?
    dir
  end

  def self.use_slave_db
    ActiveRecord::Base.establish_connection("#{Rails.env}_slave".to_sym) # конектимся к слейву
    yield
  rescue Exception => e
    logger.error("Ошибка при формировании отчета #{e}")
    raise e
  ensure
    ActiveRecord::Base.establish_connection(Rails.env.to_sym) # конектимся к основной бд
  end
end
