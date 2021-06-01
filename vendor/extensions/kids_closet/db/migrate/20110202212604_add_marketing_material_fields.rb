class AddMarketingMaterialFields < ActiveRecord::Migration
  def self.up
    add_column :sales, :facility_name, :string
    add_column :sales, :sale_hours_1, :string
    add_column :sales, :sale_hours_2, :string
    add_column :sales, :sale_hours_3, :string
    add_column :sales, :sale_hours_4, :string
    add_column :sales, :sale_hours_5, :string
  end

  def self.down
    remove_column :sales, :facility_name
    remove_column :sales, :sale_hours_1
    remove_column :sales, :sale_hours_2
    remove_column :sales, :sale_hours_3
    remove_column :sales, :sale_hours_4
    remove_column :sales, :sale_hours_5
  end
end
