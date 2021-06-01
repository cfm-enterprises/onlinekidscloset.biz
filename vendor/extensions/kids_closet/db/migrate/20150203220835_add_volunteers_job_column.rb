class AddVolunteersJobColumn < ActiveRecord::Migration
  def self.up
  	add_column :sale_volunteer_times, :none_traditional_job, :boolean, :default => false
  end

  def self.down
  	remove_column :sale_volunteer_times, :none_traditional_job
  end
end
