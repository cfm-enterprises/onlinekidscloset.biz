class AddPrimaryCardToRewardsFranchiseEmailToFranchiseAndDefaultToSale < ActiveRecord::Migration
  def self.up
    add_column :franchises, :franchise_email, :string
    add_column :rewards_profiles, :primary, :boolean, :default => false
    change_column :sales, :sale_percentage, :decimal, :precision => 6, :scale => 2, :default => 70
    change_column :sales, :sale_advert_cost, :decimal, :precision => 6, :scale => 2, :default => 12.50
    change_column :consignor_inventories, :last_day_discount, :boolean, :default => true
    remove_column :consignor_inventories, :donated_sale_id
    remove_column :transaction_imports, :end_date
    rename_column :transaction_imports, :start_date, :report_date
  end

  def self.down
    remove_column :franchises, :franchise_email
    remove_column :rewards_profiles, :primary
    add_column :transaction_imports, :end_date
    add_column :consignor_inventories, :donated_sale_id
    rename_column :transaction_imports, :report_date, :start_date
  end
end
