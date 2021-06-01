class FixSignUpTableColumnNames < ActiveRecord::Migration
  def self.up
    remove_column :sale_consignor_sign_ups, :sale_consignor_profile_id
    add_column :sale_consignor_sign_ups, :franchise_profile_id, :integer
    add_column :sale_consignor_sign_ups, :comments, :text
    add_column :sale_consignor_sign_ups, :sale_advert_cost, :decimal, :precision => 6, :scale => 2, :default => 0
    add_column :sale_consignor_sign_ups, :sale_percentage, :decimal, :precision => 6, :scale => 2, :default => 0
    remove_column :sale_volunteer_sign_ups, :sale_volunteer_profile_id
    add_column :sale_volunteer_sign_ups, :franchise_profile_id, :integer
    add_column :sale_volunteer_sign_ups, :comments, :text
  end

  def self.down
    add_column :sale_consignor_sign_ups, :sale_consignor_profile_id, :integer
    remove_column :sale_consignor_sign_ups, :franchise_profile_id
    remove_column :sale_consignor_sign_ups, :comments
    remove_column :sale_consignor_sign_ups, :sale_advert_cost
    remove_column :sale_consignor_sign_ups, :sale_percentage
    add_column :sale_volunteer_sign_ups, :sale_volunteer_profile_id, :integer
    remove_column :sale_volunteer_sign_ups, :franchise_profile_id
    remove_column :sale_volunteer_sign_ups, :comments
  end
end
