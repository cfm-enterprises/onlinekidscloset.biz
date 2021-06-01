class AssetRequirementsForInventory < ActiveRecord::Migration
  def self.up
      add_column :consignor_inventories, :display_name, :string
      add_column :consignor_inventories, :asset_file_name, :string
      add_column :consignor_inventories, :asset_content_type, :string
      add_column :consignor_inventories, :asset_file_size, :string
  end

  def self.down
      remove_column :consignor_inventories, :display_name
      remove_column :consignor_inventories, :asset_file_name
      remove_column :consignor_inventories, :asset_content_type
      remove_column :consignor_inventories, :asset_file_size
  end
end
