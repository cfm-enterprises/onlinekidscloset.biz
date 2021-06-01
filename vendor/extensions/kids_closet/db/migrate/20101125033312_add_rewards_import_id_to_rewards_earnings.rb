class AddRewardsImportIdToRewardsEarnings < ActiveRecord::Migration
  def self.up
    add_column :rewards_earnings, :rewards_import_id, :integer
    add_index :rewards_earnings, :rewards_import_id
  end

  def self.down
    remove_column :rewards_earnings, :rewards_import_id
    remove_index :rewards_earnings, :rewards_import_id
  end
end
