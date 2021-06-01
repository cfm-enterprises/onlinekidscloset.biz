namespace :kids_closet do
  desc "check number of delayed"
  task :delayed_jobs_check => :environment do
    Site.current_site_id = 1
    Franchise.check_delayed_jobs
  end
end
