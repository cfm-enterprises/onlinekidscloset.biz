class AddTwoIndexesToInventoryTable < ActiveRecord::Migration
  def self.up
    add_index :consignor_inventories, :sale_id
    add_index :consignor_inventories, [:sale_id, :profile_id]
  end

  def self.down
    remove_index :consignor_inventories, :sale_id
    remove_index :consignor_inventories, [:sale_id, :profile_id]
  end
end
