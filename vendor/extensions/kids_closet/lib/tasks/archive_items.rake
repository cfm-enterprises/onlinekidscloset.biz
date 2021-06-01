namespace :kids_closet do
  desc "archive items that were created at 29 months ago"
  task :archive_items => :environment do
    Site.current_site_id = 1
    ConsignorInventory.archive_items
  end
end
