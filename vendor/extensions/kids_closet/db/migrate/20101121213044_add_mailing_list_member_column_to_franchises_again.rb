class AddMailingListMemberColumnToFranchisesAgain < ActiveRecord::Migration
  def self.up
    add_column :franchise_profiles, :mailing_list, :boolean, :default => true
    remove_column :franchises, :mailing_list
  end

  def self.down
    remove_column :franchise_profiles, :mailing_list
    add_column :franchises, :mailing_list, :boolean, :default => true
  end
end
