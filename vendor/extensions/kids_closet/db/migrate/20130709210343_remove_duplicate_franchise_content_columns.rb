class RemoveDuplicateFranchiseContentColumns < ActiveRecord::Migration
  def self.up
  	remove_column :franchises, :about_content
  	remove_column :franchises, :links_content
  	remove_column :franchises, :charity_content
  	remove_column :franchises, :incentives_content
  	remove_column :franchises, :shoppers_info_content
  	remove_column :franchises, :volunteers_info_content
  end

  def self.down
  	add_column :franchises, :about_content, :text
  	add_column :franchises, :links_content, :text
  	add_column :franchises, :charity_content, :text
  	add_column :franchises, :incentives_content, :text
  	add_column :franchises, :shoppers_info_content, :text
  	add_column :franchises, :volunteers_info_content, :text
  end
end
