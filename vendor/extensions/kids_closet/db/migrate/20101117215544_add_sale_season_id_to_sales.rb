class AddSaleSeasonIdToSales < ActiveRecord::Migration
  def self.up
    add_column :sales, :sale_season_id, :integer
  end

  def self.down
    remove_column :sales, :sale_season_id
  end
end
