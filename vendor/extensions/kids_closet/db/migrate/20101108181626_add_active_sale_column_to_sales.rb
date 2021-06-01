class AddActiveSaleColumnToSales < ActiveRecord::Migration
  def self.up
    add_column :sales, :active, :boolean, :default => false
    add_column :sales, :sale_zip_code, :string
    add_column :sales, :tentative_date, :string
  end

  def self.down
    remove_column :sales, :active
    remove_column :sales, :sale_zip_code
    remove_column :sales, :tentative_date
  end
end
