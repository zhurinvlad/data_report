module DataReport
  class << self

    def dir_path(date = '')
      Engine.root.join('tmp', 'reports', self.class.name, (date.present? ? date : ''))
    end

    # date
    def create_dir(date = '')
      dir = dir_path(date)
      dir.mkpath unless dir.exist?
      dir
    end

    def remove_dir(date = '')
      dir_path(date).rmdir
    end


    # def self.save_report_by_day
    #   r_dir = report_by_date_dir(@params['start_period'])
    #   filename = "#{@params['mc_id']}.json"
    #   full_filename = r_dir.join(filename)
    #   begin
    #     file = File.open(full_filename, 'wb')
    #     file.write(@report_data)
    #   rescue Exception => e
    #     logger.error("Ошибка сохранения файла '#{full_filename}': #{e}")
    #   ensure
    #     file.close unless file.nil?
    #   end
    # end
    #
    # def save_report!
    #   r_dir = report_dir
    #   filename = self[:report_filename]
    #   loop do
    #     filename = SecureRandom.uuid + '.json'
    #     break unless r_dir.join(filename).exist?
    #   end if filename.blank?
    #   begin
    #     file = File.open(r_dir.join(filename), 'wb')
    #     file.write(@data)
    #   rescue Exception => e
    #     logger.error("Ошибка сохранения файла #{e}")
    #     update_attributes(status: :error)
    #     raise e
    #   else
    #     update_attributes(status: :processed, report_filename: filename)
    #   ensure
    #     file.close unless file.nil?
    #   end
    # end
    #
    # def load_report!
    #   file = File.open(report_dir.join(self[:report_filename]), 'rb')
    #   @data = JSON.parse(file.read)
    # rescue IOError => e
    #   logger.error("Ошибка чтения файла отчетов #{self[:report_filename]}")
    #   raise e
    # ensure
    #   file.close unless file.nil?
    # end
    #
    # def self.use_slave_db
    #   ActiveRecord::Base.establish_connection("#{Rails.env}_slave".to_sym) # конектимся к слейву
    #   yield
    # rescue Exception => e
    #   logger.error("Ошибка при формировании отчета #{e}")
    #   raise e
    # ensure
    #   ActiveRecord::Base.establish_connection(Rails.env.to_sym) # конектимся к основной бд
    # end
    #


  end
end