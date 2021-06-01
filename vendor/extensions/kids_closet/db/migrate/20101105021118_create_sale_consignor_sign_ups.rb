class CreateSaleConsignorSignUps < ActiveRecord::Migration
  def self.up
    create_table :sale_consignor_sign_ups do |t|
      t.integer :sale_consignor_time_id
      t.integer :sale_consignor_profile_id
      t.boolean :approved, :default => false
      t.timestamps
    end

    add_index :sale_consignor_sign_ups, :sale_consignor_time_id
  end


  def self.down
    drop_table :sale_consignor_sign_ups
  end
end
