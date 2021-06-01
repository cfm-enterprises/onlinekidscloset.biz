class CreateFranchiseRewardsAdjustments < ActiveRecord::Migration
  def self.up
    create_table :franchise_rewards_adjustments do |t|
    	t.integer :franchise_id, :site_id, :rewards_profile_id, :amount
    	t.text :comment
      t.timestamps
    end
  end

  def self.down
    drop_table :franchise_rewards_adjustments
  end
end
