class CreateFranchises < ActiveRecord::Migration
  def self.up
    create_table :franchises do |t|
      t.string :franchise_name, :facebook_url, :twitter_url, :blogger_url, :sale_hash, :sale_city
      t.integer :province_id
      t.timestamps
    end
    
    add_index :franchises, :franchise_name
    
  end

  def self.down
    drop_table :franchises
  end
end
