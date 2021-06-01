namespace :kids_closet do
  desc "assign all items to be sold online as belonging to franchise 1"
  task :prepare_online_items => :environment do
    Site.current_site_id = 1
#    items = ConsignorInventory.find(:all, :conditions => ["status = ? AND (donate_date = ? || donate_date IS NULL) AND bring_to_sale = ? AND featured_item = ?", false, '', true, true])
#    for item in items
#	    if item.item_franchise_relationship.nil?
#		    relationship = ItemFranchiseRelationship.new
#		    relationship.consignor_inventory_id = item.id
#		    relationship.franchise_id = 77
#		    relationship.save
#		  end
#		end
  end
end
