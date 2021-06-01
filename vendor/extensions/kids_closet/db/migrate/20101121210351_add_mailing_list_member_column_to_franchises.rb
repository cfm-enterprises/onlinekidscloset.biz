class AddMailingListMemberColumnToFranchises < ActiveRecord::Migration
  def self.up
    add_column :franchises, :mailing_list, :boolean, :default => true
  end

  def self.down
    remove_column :franchises, :mailing_list
  end
end
