class AddNewConsignorColumnToFranchiseProfile < ActiveRecord::Migration
  def self.up
    add_column :franchise_profiles, :new_consignor, :boolean, :default => false
  end

  def self.down
    remove_column :franchise_profiles, :new_consignor
  end
end
