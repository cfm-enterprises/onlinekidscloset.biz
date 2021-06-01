class CreateTableForKidsEmails < ActiveRecord::Migration
  def self.up
  	add_column :kids_emails, :subject, :string
  	add_column :kids_emails, :text_body, :text
  	add_column :kids_emails, :html_body, :text
  	add_column :kids_emails, :franchise_id, :integer
  	add_column :kids_emails, :recipients, :string
  	add_column :kids_emails, :draft_recipient, :string
  	add_column :kids_emails, :master_email, :boolean, :default => false
  end

  def self.down
  	remove_column :kids_emails, :subject
  	remove_column :kids_emails, :text_body
  	remove_column :kids_emails, :html_body
  	remove_column :kids_emails, :franchise_id
  	remove_column :kids_emails, :recipients
  	remove_column :kids_emails, :draft_recipient
  	remove_column :kids_emails, :master_email
  end
end
