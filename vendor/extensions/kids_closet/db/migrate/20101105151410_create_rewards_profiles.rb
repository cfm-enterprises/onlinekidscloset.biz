class CreateRewardsProfiles < ActiveRecord::Migration
  def self.up
    create_table :rewards_profiles do |t|
      t.integer :profile_id
      t.integer :rewards_number
      t.timestamps
    end

    add_index :rewards_profiles, :rewards_number
  end

  
  def self.down
    drop_table :rewards_profiles
  end
end
