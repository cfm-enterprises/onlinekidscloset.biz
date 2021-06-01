class AddBadEmailColumnToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :bad_email, :boolean, :default => false
  end

  def self.down
    remove_column :profiles, :bad_email
  end
end
