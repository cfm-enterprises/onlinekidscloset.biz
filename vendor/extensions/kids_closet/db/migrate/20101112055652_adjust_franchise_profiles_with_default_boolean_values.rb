class AdjustFranchiseProfilesWithDefaultBooleanValues < ActiveRecord::Migration
  def self.up
    change_column :franchise_profiles, :consignor, :boolean, :default => false
    change_column :franchise_profiles, :volunteer, :boolean, :default => false
    change_column :franchise_profiles, :active, :boolean, :default => true
    remove_column :consignor_inventories, :boolean
    change_column :consignor_inventories, :discounted_at_sale, :boolean, :default => false
    change_column :transaction_imports, :processed, :boolean, :default => false
  end

  def self.down
    add_column :consignor_inventories, :boolean, :integer
  end
end
