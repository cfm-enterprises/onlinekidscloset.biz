class ChangeDefaultForMinimumRoyaltyToTrue < ActiveRecord::Migration
  def self.up
  	change_column :franchises, :use_minimum_royalty, :boolean, :default => true
  end

  def self.down
  	change_column :franchises, :use_minimum_royalty, :boolean, :default => false
  end
end
