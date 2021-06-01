class ChangeBadColumnName < ActiveRecord::Migration
  def self.up
    rename_column :rewards_profiles, :primary, :primary_card
  end

  def self.down
    rename_column :rewards_profiles, :primary_card, :primary
  end
end
