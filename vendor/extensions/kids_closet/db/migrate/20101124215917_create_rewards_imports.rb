class CreateRewardsImports < ActiveRecord::Migration
  def self.up
    create_table :rewards_imports do |t|
      t.integer :sale_id, :site_id, :site_asset_id
      t.date :rewards_date
      t.timestamps
    end
    add_index :rewards_imports, :sale_id
  end

  def self.down
    drop_table :rewards_imports
  end
end
