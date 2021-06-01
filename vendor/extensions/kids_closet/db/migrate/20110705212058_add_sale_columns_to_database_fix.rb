class AddSaleColumnsToDatabaseFix < ActiveRecord::Migration
  def self.up
    add_column :sales, :tax_received, :decimal, :precision => 6, :scale => 2, :default => 0
    add_column :sales, :transaction_count, :integer, :default => 0
  end

  def self.down
    remove_column :sales, :tax_received
    remove_column :sales, :transaction_count
  end
end
