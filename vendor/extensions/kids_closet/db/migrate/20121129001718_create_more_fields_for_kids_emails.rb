class CreateMoreFieldsForKidsEmails < ActiveRecord::Migration
  def self.up
  	add_column :kids_emails, :sent_at, :datetime
  	add_column :kids_emails, :estimated_number_of_emails, :integer
  end

  def self.down
  	remove_column :kids_emails, :sent_at
  	remove_column :kids_emails, :estimated_number_of_emails
  end
end
