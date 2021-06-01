class AddItemsComingColumnToSales < ActiveRecord::Migration
  def self.up
  	add_column :sales, :items_coming, :integer
  end

  def self.down
  	remove_column :sales, :items_coming
  end
end
