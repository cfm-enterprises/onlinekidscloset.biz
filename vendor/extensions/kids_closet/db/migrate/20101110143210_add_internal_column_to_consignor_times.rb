class AddInternalColumnToConsignorTimes < ActiveRecord::Migration
  def self.up
    add_column :sale_consignor_times, :internal, :boolean, :default => false
  end

  def self.down
    remove_column :sale_consignor_times, :internal
  end
end
