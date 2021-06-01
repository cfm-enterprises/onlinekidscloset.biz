class CreateRewardProfileSearches < ActiveRecord::Migration
  def self.up
    create_table :reward_profile_searches do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :reward_profile_searches
  end
end
