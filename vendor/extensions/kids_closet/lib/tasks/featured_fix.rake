namespace :kids_closet do
  desc "set featured items to new database"
  task :featured_fix => :environment do
    Site.current_site_id = 1
    ConsignorInventory.featured_items_fix
  end
end
