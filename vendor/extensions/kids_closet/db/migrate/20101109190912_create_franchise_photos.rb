class CreateFranchisePhotos < ActiveRecord::Migration
  def self.up
    create_table :franchise_photos do |t|
      t.integer :franchise_id, :site_asset_id
      t.string :caption
      t.timestamps
    end
  
    add_index :franchise_photos, :franchise_id
  end
  

  def self.down
    drop_table :franchise_photos
  end
end
