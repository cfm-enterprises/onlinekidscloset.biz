class AddSiteAssetIdToBusinessPartners < ActiveRecord::Migration
  def self.up
    add_column :business_partners, :site_asset_id, :integer
  end

  def self.down
    remove_column :business_partners, :site_asset_id
  end
end
