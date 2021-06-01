class ShoppingCartEnhancements < ActiveRecord::Migration
  def self.up
  	add_column :orders, :pay_pal_order_id, :integer
  end

  def self.down
  	remove_column :orders, :pay_pal_order_id
  end
end
