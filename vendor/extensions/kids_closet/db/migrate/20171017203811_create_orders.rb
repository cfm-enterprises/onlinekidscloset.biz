class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
    	t.integer :consignor_inventory_id
    	t.string :item_name
    	t.decimal :item_price, :precision => 6, :scale => 2
    	t.decimal :sales_tax, :precision => 6, :scale => 2
    	t.decimal :total_amount, :precision => 6, :scale => 2
    	t.integer :sale_id
    	t.integer :buyer_id
    	t.integer :seller_id
    	t.datetime :ordered_at
    	t.datetime :purchased_at
      t.timestamps

    end
  end

  def self.down
    drop_table :orders
  end
end
