class CreateFranchiseFiles < ActiveRecord::Migration
  def self.up
    create_table :franchise_files do |t|
      t.integer :franchise_file_category_id, :site_asset_id
      t.string :file_description
      t.timestamps
    end
  end

  def self.down
    drop_table :franchise_files
  end
end
