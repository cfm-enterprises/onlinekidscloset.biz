class AddSomeIndexes < ActiveRecord::Migration
  def self.up
    add_index :sales, :sale_season_id
    add_index :consignor_inventories, :rewards_profile_id
    add_index :consignor_inventories, :transaction_import_id
    add_index :rewards_profiles, :profile_id
    add_index :franchise_file_categories, :title
    add_index :franchise_files, :franchise_file_category_id
    add_index :sale_seasons, :start_date
  end

  def self.down
    remove_index :sales, :sale_season_id
    remove_index :consignor_inventories, :rewards_profile_id
    remove_index :consignor_inventories, :transaction_import_id
    remove_index :rewards_profiles, :profile_id
    remove_index :franchise_file_categories, :title
    remove_index :franchise_files, :franchise_file_category_id
    remove_index :sale_seasons, :start_date
  end
end
