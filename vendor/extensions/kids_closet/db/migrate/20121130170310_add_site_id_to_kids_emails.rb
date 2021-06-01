class AddSiteIdToKidsEmails < ActiveRecord::Migration
  def self.up
  	add_column :kids_emails, :site_id, :integer
  end

  def self.down
  	remove_column :kids_emails, :site_id
  end
end
