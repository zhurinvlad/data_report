namespace :db do
  desc "Rake task to remove old reports"
  task :clean_old_reports => :environment do
    IaReport.clean_old_reports!
  end
end
