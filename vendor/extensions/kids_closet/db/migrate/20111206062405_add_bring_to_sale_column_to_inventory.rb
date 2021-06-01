class AddBringToSaleColumnToInventory < ActiveRecord::Migration
  def self.up
    add_column :consignor_inventories, :bring_to_sale, :boolean, :default => false
  end

  def self.down
    remove_column :consignor_inventories, :bring_to_sale
  end
end
