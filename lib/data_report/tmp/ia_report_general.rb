class IaReportGeneral < IaReportLib
  include ActionView::Helpers::NumberHelper

  # NOTE: MZh Да, я знаю, что рендерить view из модели - bad idea
  # но это позволит хранить один шаблон для рендеринга и в Jobs и в Controller
  def to_html(opts)
    render_anywhere('api/v1/reports/report_general_template.html.erb',
                    columns: @columns,
                    data: opts['data'],
                    title: opts['title'])
  end

  def to_csv(opts)
    CSV.generate(col_sep: ';', row_sep: "\r\n", encoding: 'cp1251') do |csv|
      csv << [opts['title']]
      csv << @columns
      opts['data'].each { |trans| csv << trans.values }
    end
  end

  def to_pdf(opts)
    return nil if opts['data'].nil?
    data = opts['data'].map(&:values)
    pdf = Prawn::Document.new(page_layout: :landscape)
    pdf.font_families.update(
      'MyTypeFamily' => { bold:   "#{Rails.root.join('vendor', 'assets', 'fonts')}/OpenSans-Bold.ttf",
                          normal: "#{Rails.root.join('vendor', 'assets', 'fonts')}/OpenSans-Regular.ttf" })
    pdf.font('MyTypeFamily', style: :normal)
    pdf.text opts['title']
    pdf.text ' '
    pdf.font_size 7
    if data.any?
      data.unshift(@columns)
      pdf.table data, header: true, cell_style: { align: :center, padding: 2, border_width: 0.5 } do
        row(0).font_style = :bold
        column(0).width = 110
        column(1..3).width = 55
        column([5, 10]).width = 55
        column([2, 9]).width = 60
      end
    else
      pdf.table [@columns], cell_style: { align: :center } do
        row(0).font_style = :bold
        column([0, 2, 5, 7, 9]).width = 60
      end
    end
    pdf.render
  end

  def to_xlsx(opts)
    xls = Axlsx::Package.new
    xls.workbook do |wb|
      wb.add_worksheet(name: 'Отчет') do |sheet|
        money = wb.styles.add_style format_code: '0.00'
        sheet.add_row [opts['title']]
        sheet.add_row @columns
        sheet.column_widths 40, 20, 20, 20, 15, 20, 20, 30, 30, 30, 25, 30
        opts['data'].each do |st|
          sheet.add_row [
            st[@columns[0]],      st[@columns[1]],      st[@columns[2]],
            st[@columns[3]],      st[@columns[4]].to_f, st[@columns[5]],
            st[@columns[6]].to_f, st[@columns[7]].to_f, st[@columns[8]],
            st[@columns[9]],      st[@columns[10]],     st[@columns[11]],
            st[@columns[12]],     st[@columns[13]]
          ],
          types: [:string, :string, :string, nil, :float, :string,
                  :float, :float, nil, nil, nil, :string, nil],
          style: [nil, nil, nil, nil, money, nil, money, money]
        end
      end
    end
    xls.to_stream.read
  end

  # Здесь лежат необходимые данные для отчета
  def self.set_required_params
    return 'sp_reports_OpsForPeriodWithBank',                    # @cmd
            %w(start_period end_period mc_id processing_id),     # @required_params
    [                                                            # @columns
                  'Контракт',                # 0
                  'Номер заказа',            # 1
                  'RRN',                     # 2
                  'Дата транзакции',         # 3
                  'Сумма платежа',           # 4
                  'Код валюты',              # 5
                  'Комиссия',                # 6
                  'Сумма к выплате',         # 7
                  'Статус оплаты',           # 8
                  'Имя держателя карты',     # 9
                  'Номер карты',             # 10
                  'МПС',                     # 11
                  'Способ оплаты',           # 12
                  'Банк'                     # 13
    ]
  end
end
