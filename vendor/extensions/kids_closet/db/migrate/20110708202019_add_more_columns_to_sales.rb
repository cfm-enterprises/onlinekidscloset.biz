class AddMoreColumnsToSales < ActiveRecord::Migration
  def self.up
    add_column :sales, :total_items_sold, :integer, :default => 0
    add_column :sales, :total_amount_sold, :decimal, :precision => 6, :scale => 2, :default => 0
  end

  def self.down
    remove_column :sales, :total_items_sold
    remove_column :sales, :total_amount_sold
  end
end
