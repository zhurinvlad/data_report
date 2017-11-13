namespace :reports do
  desc 'Generate reports'
  task :create, [:file_token] => :environment do |_, args|
    check_count = 1
    check_max_count = 60*30
    report_id = args[:file_token]
    done = false
    (check_count..check_max_count).each do
      active_reports = IaReport.processing.where('updated_at > ?', Time.zone.now - 30.minutes)
      if active_reports.count > 4
        sleep 1
        next
      end
      report = IaReport.unscoped.find(report_id)
      return if report.deleted
      report.generate_report
      ReportMailer.report_email(report).deliver_later unless report.email.blank?
      done = true
      break
    end
    IaReport.unscoped.find(report_id).update(status: :error) unless done
  end

  task :generate, [:begin_date, :end_date] => :environment do |_, args|
    begin_date = end_date = nil
    begin_date = Date.new(*args[:begin_date].split('-').map(&:to_i)) unless args[:begin_date].blank?
    end_date   = Date.new(*args[:end_date].split('-').map(&:to_i)) unless args[:end_date].blank?
    begin_date = Date.today - 1.day if begin_date.nil?
    end_date = begin_date if end_date.nil?
    (begin_date..end_date).each do |date|
      IaReportGeneral.generate_for_date(date.strftime('%Y-%m-%d'))
      IaReportAntifraud.generate_for_date(date.strftime('%Y-%m-%d'))
    end
  end
end
