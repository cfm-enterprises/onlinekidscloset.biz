class ChangeDefaultSalePercentage < ActiveRecord::Migration
  def self.up
    change_column :sales, :sale_percentage, :decimal, :precision => 6, :scale => 2, :default => 65
  end

  def self.down
    change_column :sales, :sale_percentage, :decimal, :precision => 6, :scale => 2, :default => 70
  end
end
