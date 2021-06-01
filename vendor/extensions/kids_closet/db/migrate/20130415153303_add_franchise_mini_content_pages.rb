class AddFranchiseMiniContentPages < ActiveRecord::Migration
  def self.up
  	add_column :franchises, :consignors_info_content, :text
  	add_column :franchises, :shoppers_info_content, :text
  	add_column :franchises, :volunteers_info_content, :text
  end

  def self.down
  	remove_column :franchises, :consignors_info_content
  	remove_column :franchises, :shoppers_info_content
  	remove_column :franchises, :volunteers_info_content
  end
end
