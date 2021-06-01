class EmailScheduleLink < ActiveRecord::Migration
  def self.up
  	add_column :delayed_jobs, :kids_email_id, :integer
  end

  def self.down
  	remove_column :delayed_jobs, :kids_email_id
  end
end
