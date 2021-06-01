class AddPromoCodeToSaleConsignorSignUps < ActiveRecord::Migration
  def self.up
  	add_column :sale_consignor_sign_ups, :promo_code, :string
  end

  def self.down
  	remove_column :sale_consignor_sign_ups, :promo_code
  end
end
