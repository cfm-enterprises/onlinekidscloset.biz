class CreateRewardsEarnings < ActiveRecord::Migration
  def self.up
    create_table :rewards_earnings do |t|
      t.integer :rewards_profile_id, :sale_id
      t.integer :amount_applied
      t.timestamps
    end

    add_index :rewards_earnings, :sale_id
    add_index :rewards_earnings, :rewards_profile_id
  end


  def self.down
    drop_table :rewards_earnings
  end
end
