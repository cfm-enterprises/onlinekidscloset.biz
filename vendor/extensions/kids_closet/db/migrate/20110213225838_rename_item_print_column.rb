class RenameItemPrintColumn < ActiveRecord::Migration
  def self.up
    rename_column :consignor_inventories, :print, :printed
  end

  def self.down
    rename_column :consignor_inventories, :printed, :print
  end
end
