class AddAssetFieldsToFranchisePhotos < ActiveRecord::Migration
  def self.up
      add_column :franchise_photos, :display_name, :string
      add_column :franchise_photos, :asset_file_name, :string
      add_column :franchise_photos, :asset_content_type, :string
      add_column :franchise_photos, :asset_file_size, :string
  end

  def self.down
      remove_column :franchise_photos, :display_name
      remove_column :franchise_photos, :asset_file_name
      remove_column :franchise_photos, :asset_content_type
      remove_column :franchise_photos, :asset_file_size
  end
end
