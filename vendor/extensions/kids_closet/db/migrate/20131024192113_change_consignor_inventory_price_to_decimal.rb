class ChangeConsignorInventoryPriceToDecimal < ActiveRecord::Migration
  def self.up
  	change_column :consignor_inventories, :price, :decimal, :precision => 6, :scale => 2, :default => 0
  end

  def self.down
  end
end
