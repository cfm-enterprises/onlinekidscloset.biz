class AllowForMoreLargerDecimals < ActiveRecord::Migration
  def self.up
    change_column :sale_consignor_sign_ups, :percentage_fee_paid, :decimal, :precision => 8, :scale => 2, :default => 0
    change_column :sale_consignor_sign_ups, :total_sold, :decimal, :precision => 8, :scale => 2, :default => 0
  end

  def self.down
  end
end
