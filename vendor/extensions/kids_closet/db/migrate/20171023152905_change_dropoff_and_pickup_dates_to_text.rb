class ChangeDropoffAndPickupDatesToText < ActiveRecord::Migration
  def self.up
    change_column :sales, :online_sale_drop_off_date, :string
    change_column :sales, :online_sale_pickup_date, :string
  end

  def self.down
  end
end
