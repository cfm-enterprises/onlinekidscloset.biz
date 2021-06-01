class CreatePayPalOrders < ActiveRecord::Migration
  def self.up
    create_table :pay_pal_orders do |t|
    	t.integer :profile_id
    	t.integer :sale_id
    	t.datetime :ordered_at
    	t.datetime :purchased_at
      t.timestamps

    end
  end

  def self.down
    drop_table :pay_pal_orders
  end
end
