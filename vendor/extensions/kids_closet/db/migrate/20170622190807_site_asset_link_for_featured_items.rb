class SiteAssetLinkForFeaturedItems < ActiveRecord::Migration
  def self.up
  	add_column :consignor_inventories, :featured_item, :boolean, :default => false
  end

  def self.down
  	remove_column :consignor_inventories, :featured_item
  end
end
