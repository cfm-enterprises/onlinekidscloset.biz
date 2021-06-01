class AddNameToSaleSeasons < ActiveRecord::Migration
  def self.up
    add_column :sale_seasons, :season_name, :string
    change_column :consignor_inventories, :price, :integer, :default => 0
  end

  def self.down
    remove_column :sale_seasons, :season_name
  end
end
