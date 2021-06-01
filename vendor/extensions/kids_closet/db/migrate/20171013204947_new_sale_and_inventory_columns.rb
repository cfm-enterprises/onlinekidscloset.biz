class NewSaleAndInventoryColumns < ActiveRecord::Migration
  def self.up
  	add_column :sales, :has_online_sale, :boolean, :default => false
  	add_column :sales, :online_sale_start_date, :datetime
  	add_column :sales, :online_sale_end_date, :datetime
  	add_column :sales, :online_sale_drop_off_date, :date
  	add_column :sales, :online_sale_pickup_date, :date
  	add_column :sales, :tax_rate, :decimal, :precision => 6, :scale => 2, :default => 0 
  	add_column :consignor_inventories, :sold_online, :boolean, :default => false
  	add_column :consignor_inventories, :additional_information, :string	
  end

  def self.down
  end
end
