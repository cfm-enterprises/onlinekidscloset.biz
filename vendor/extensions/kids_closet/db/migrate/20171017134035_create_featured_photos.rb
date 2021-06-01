class CreateFeaturedPhotos < ActiveRecord::Migration
  def self.up
    create_table :featured_photos do |t|
    	t.integer :consignor_inventory_id
      t.string :display_name
      t.string :asset_file_name
      t.string :asset_content_type
      t.string :asset_file_size
      t.integer :rotation
      t.timestamps
    end
  end

  def self.down
    drop_table :featured_photos
  end
end
