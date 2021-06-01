class AllowForLargerDecimals < ActiveRecord::Migration
  def self.up
    change_column :sales, :tax_received, :decimal, :precision => 8, :scale => 2, :default => 0
    change_column :sales, :total_amount_sold, :decimal, :precision => 8, :scale => 2, :default => 0
    change_column :rewards_profile_sale_results, :amount_purchased, :decimal, :precision => 8, :scale => 2, :default => 0
  end

  def self.down
  end
end
