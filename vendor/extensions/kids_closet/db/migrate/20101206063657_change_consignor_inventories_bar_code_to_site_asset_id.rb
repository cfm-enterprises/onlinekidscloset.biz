class ChangeConsignorInventoriesBarCodeToSiteAssetId < ActiveRecord::Migration
  def self.up
    remove_column :consignor_inventories, :bar_code
    add_column :consignor_inventories, :site_asset_id, :integer
  end

  def self.down
    add_column :consignor_inventories, :bar_code, :integer
    remove_column :consignor_inventories, :site_asset_id
  end
end
