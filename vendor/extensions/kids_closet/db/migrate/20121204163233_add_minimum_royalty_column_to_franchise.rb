class AddMinimumRoyaltyColumnToFranchise < ActiveRecord::Migration
  def self.up
  	add_column :franchises, :use_minimum_royalty, :boolean, :default => false
  end

  def self.down
  	remove_column :franchises, :use_minimum_royalty
  end
end
