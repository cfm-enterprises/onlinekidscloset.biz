class ChangeBringToSaleDefault < ActiveRecord::Migration
  def self.up
    change_column :consignor_inventories, :bring_to_sale, :boolean, :default => true
  end

  def self.down
    change_column :consignor_inventories, :bring_to_sale, :boolean, :default => false
  end
end
