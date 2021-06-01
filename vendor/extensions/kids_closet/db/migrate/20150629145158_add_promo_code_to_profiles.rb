class AddPromoCodeToProfiles < ActiveRecord::Migration
  def self.up
  	add_column :profiles, :promo_code, :string
  end

  def self.down
  	remove_column :profiles, :promo_code
  end
end
