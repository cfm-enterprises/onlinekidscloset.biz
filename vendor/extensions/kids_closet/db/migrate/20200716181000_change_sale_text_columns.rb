class ChangeSaleTextColumns < ActiveRecord::Migration
  def self.up
  	change_column :sales, :online_sale_drop_off_date, :text
  	change_column :sales, :online_sale_pickup_date, :text
  end

  def self.down
  end
end
