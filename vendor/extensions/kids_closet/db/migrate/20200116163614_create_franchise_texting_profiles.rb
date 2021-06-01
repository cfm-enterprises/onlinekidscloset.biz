class CreateFranchiseTextingProfiles < ActiveRecord::Migration
  def self.up
    create_table :franchise_texting_profiles do |t|
    	t.integer :site_id, :franchise_id
    	t.string :phone

      t.timestamps

    end
  end

  def self.down
    drop_table :franchise_texting_profiles
  end
end
