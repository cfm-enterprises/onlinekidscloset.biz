class AllowOnlineSaleDiscount < ActiveRecord::Migration
  def self.up
  	add_column :sales, :allow_online_discount, :boolean, :default => true
  end

  def self.down
  	remove_column :sales, :allow_online_discount
  end
end
