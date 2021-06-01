class AddCategoryAndSubCategory < ActiveRecord::Migration
  def self.up
  	add_column :consignor_inventories, :category, :string
  	add_column :consignor_inventories, :sub_category, :string
  end

  def self.down
  	remove_column :consignor_inventories, :category
  	remove_column :consignor_inventories, :sub_category
  end
end
