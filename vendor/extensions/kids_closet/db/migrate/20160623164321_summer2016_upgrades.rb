class Summer2016Upgrades < ActiveRecord::Migration
  def self.up
  	add_column :kids_emails, :draft_mode, :boolean, :default => false
  	add_column :kids_emails, :schedule_email, :boolean, :default => false
  	add_column :kids_emails, :send_at, :datetime
  	add_column :kids_master_emails, :draft_mode, :boolean, :default => false
  	add_column :kids_master_emails, :schedule_email, :boolean, :default => false
  	add_column :kids_master_emails, :send_at, :datetime
  	add_column :franchises, :facebook_pixel, :string
  	add_column :sale_volunteer_times, :draft_status, :boolean, :default => false
  end

  def self.down
  	remove_column :kids_emails, :draft_mode
  	remove_column :kids_emails, :schedule_email, :boolean
  	remove_column :kids_emails, :send_at
  	remove_column :kids_master_emails, :draft_mode
  	remove_column :kids_master_emails, :schedule_email, :boolean
  	remove_column :kids_master_emails, :send_at
  	remove_column :franchises, :facebook_pixel
  	remove_column :sale_volunteer_times, :draft_status
  end
end
