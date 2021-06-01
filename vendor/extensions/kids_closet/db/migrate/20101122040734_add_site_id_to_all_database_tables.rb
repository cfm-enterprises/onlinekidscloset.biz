class AddSiteIdToAllDatabaseTables < ActiveRecord::Migration
  def self.up
    add_column :consignor_inventories, :site_id, :integer, :default => 1
    add_column :franchises, :site_id, :integer, :default => 1
    add_column :franchise_files, :site_id, :integer, :default => 1
    add_column :franchise_file_categories, :site_id, :integer, :default => 1
    add_column :franchise_owner_profiles, :site_id, :integer, :default => 1
    add_column :franchise_photos, :site_id, :integer, :default => 1
    add_column :franchise_profiles, :site_id, :integer, :default => 1
    add_column :rewards_earnings, :site_id, :integer, :default => 1
    add_column :rewards_profiles, :site_id, :integer, :default => 1
    add_column :sales, :site_id, :integer, :default => 1
    add_column :sale_consignor_sign_ups, :site_id, :integer, :default => 1
    add_column :sale_consignor_times, :site_id, :integer, :default => 1
    add_column :sale_seasons, :site_id, :integer, :default => 1
    add_column :sale_volunteer_sign_ups, :site_id, :integer, :default => 1
    add_column :sale_volunteer_times, :site_id, :integer, :default => 1
    add_column :transaction_imports, :site_id, :integer, :default => 1
  end

  def self.down
    remove_column :consignor_inventories, :site_id
    remove_column :franchises, :site_id
    remove_column :franchise_files, :site_id
    remove_column :franchise_file_categories, :site_id
    remove_column :franchise_owner_profiles, :site_id
    remove_column :franchise_photos, :site_id
    remove_column :franchise_profiles, :site_id
    remove_column :rewards_earnings, :site_id
    remove_column :rewards_profiles, :site_id
    remove_column :sales, :site_id
    remove_column :sale_consignor_sign_ups, :site_id
    remove_column :sale_consignor_times, :site_id
    remove_column :sale_seasons, :site_id
    remove_column :sale_volunteer_sign_ups, :site_id
    remove_column :sale_volunteer_times, :site_id
    remove_column :transaction_imports, :site_id
  end
end
