class CreateFranchiseHomeContents < ActiveRecord::Migration
  def self.up
    create_table :franchise_home_contents do |t|
      t.integer :site_id, :franchise_id
      t.text :owner_photo_content, :meet_the_owner_content, :franchise_rewards_content
      t.timestamps
    end
  end

  def self.down
    drop_table :franchise_home_contents
  end
end
