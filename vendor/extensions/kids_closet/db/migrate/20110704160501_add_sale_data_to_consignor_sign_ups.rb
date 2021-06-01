class AddSaleDataToConsignorSignUps < ActiveRecord::Migration
  def self.up
    add_column :sale_consignor_sign_ups, :quantity_sold, :integer, :default => 0
    add_column :sale_consignor_sign_ups, :total_sold, :decimal, :precision => 6, :scale => 2, :default => 0
    add_column :sale_consignor_sign_ups, :advertisement_fee_paid, :decimal, :precision => 6, :scale => 2, :default => 0
    add_column :sale_consignor_sign_ups, :percentage_fee_paid, :decimal, :precision => 6, :scale => 2, :default => 0
  end

  def self.down
    remove_column :sale_consignor_sign_ups, :quantity_sold
    remove_column :sale_consignor_sign_ups, :total_sold
    remove_column :sale_consignor_sign_ups, :advertisement_fee_paid
    remove_column :sale_consignor_sign_ups, :percentage_fee_paid
  end
end
