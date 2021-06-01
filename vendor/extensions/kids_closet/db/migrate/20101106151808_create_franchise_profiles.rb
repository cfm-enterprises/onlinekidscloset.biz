class CreateFranchiseProfiles < ActiveRecord::Migration
  def self.up
    create_table :franchise_profiles do |t|
      t.integer :franchise_id, :profile_id
      t.boolean :consignor, :volunteer, :active
      t.timestamps
    end
    
    add_index :franchise_profiles, :franchise_id
    add_index :franchise_profiles, :profile_id
    add_index :franchise_profiles, [:franchise_id, :profile_id]
  end

  def self.down
    drop_table :franchise_profiles
  end
end
