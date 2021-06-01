class CreateRewardsProfileSaleResults < ActiveRecord::Migration
  def self.up
    create_table :rewards_profile_sale_results do |t|
      t.integer :sale_id, :rewards_profile_id, :site_id
      t.decimal :amount_purchased, :precision => 6, :scale => 2, :default => 0
      t.timestamps
    end

    add_index :rewards_profile_sale_results, [:rewards_profile_id, :sale_id]
    add_index :rewards_profile_sale_results, :sale_id
  end

  def self.down
    drop_table :rewards_profile_sale_results
  end
end
