class CreateConsignorInventories < ActiveRecord::Migration
  def self.up
    create_table :consignor_inventories do |t|
      t.integer :profile_id, :bar_code
      t.decimal :price, :precision => 6, :scale => 2
      t.string :item_description
      t.string :size, :import_error_comment
      t.boolean :last_day_discount, :default => false
      t.boolean :status, :default => false
      t.boolean :donate, :default => false
      t.boolean :print, :default => false
      t.integer :transaction_import_id
      t.integer :sale_id
      t.integer :discounted_at_sale, :boolean
      t.decimal :sale_price, :precision => 6, :scale => 2
      t.decimal :tax_collected, :precision => 6, :scale => 2
      t.decimal :total_price, :precision => 6, :scale => 2
      t.date :sale_date
      t.integer :transaction_number
      t.integer :donated_sale_id
      t.date :donate_date
      t.integer :rewards_profile_id
      t.timestamps
    end

    add_index :consignor_inventories, [:profile_id, :item_description]
    add_index :consignor_inventories, [:sale_id, :profile_id, :item_description]
  end
  

  def self.down
    drop_table :consignor_inventories
  end
end
