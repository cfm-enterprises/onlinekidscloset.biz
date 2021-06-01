class Spring2016Updates < ActiveRecord::Migration
  def self.up
  	add_column :sale_consignor_sign_ups, :fee_adjustment, :decimal, :precision => 8, :scale => 2, :default => 0
  end

  def self.down
  	remove_column :sale_consignor_sign_ups, :fee_adjustment
  end
end
