class CreateFranchiseOwnerProfiles < ActiveRecord::Migration
  def self.up
    create_table :franchise_owner_profiles do |t|
      t.integer :franchise_id, :profile_id
      t.timestamps
    end
  
    add_index :franchise_owner_profiles, :franchise_id
    add_index :franchise_owner_profiles, :profile_id
    add_index :franchise_owner_profiles, [:franchise_id, :profile_id]
  end
    
  def self.down
    drop_table :franchise_owner_profiles
  end
end
