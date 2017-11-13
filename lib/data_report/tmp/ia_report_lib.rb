class IaReportLib < IaReport
  # Тут лежат необходимые методы для отчетов antifraud и general

  def initialize(*args)
    super
    init_params
  end

  def init_params
    super
    return if @general_inited
    @general_inited = true
    @params = begin
                JSON.parse(report_params)
              rescue
                {}
              end
    @cmd, @required_params, @columns = self.class.set_required_params
    @merchant = @params['mc_id'] == 'all' ? 'Все' : MerchantContract.find(@params['mc_id']).long_name
    @bank = @params['processing_id'] == 'all' ? 'Все' : Processing.find(@params['processing_id'])['Name']
  end

  def self.generate_for_date(date)
    MerchantContract.all.each { |mc| self.generate_for_mc_by_date(mc.id, date) }
  end

  def self.generate_for_mc_by_date(mc_id, date)
    @cmd, @required_params, @columns = set_required_params
    @params = {'start_period' => date,
               'end_period' => date,
               'processing_id' => -1}
    @params['mc_id'] = mc_id
    @report_data = select_all.to_json
    self.save_report_by_day
  end

  def generate
    init_params
    data = get_new_report(@params['start_period'], @params['end_period'], @params['mc_id'],  @params['processing_id'], self.format.to_s)
    {
        'data_format' => :zip,
        'data' => Base64.encode64(data)
    }
  end

  def get_report(report_format)
    init_params
    load_report!
    @data
  end

  def to_format(format)
    fail NotImplementedError
  end

  def validate_params
    init_params unless @general_inited
    return false unless super
    case @params['mc_id']
      when 'all'
        # return false unless @report.user.permissions?(Permission::LIST[:get_deals_for_many_merchants])
        user.permissions!([Permission::LIST[:get_deals_for_many_merchants]])
        true
      else
        merchant_contract_id = @params['mc_id'].to_i
        !user.allowed_merchant_contract(merchant_contract_id).nil?
    end
  end

  def formated_report_params
    init_params
    {
        merchant: @merchant,
        bank: @bank,
        start: @params['start_period'],
        end: @params['end_period']
    }
  end

end