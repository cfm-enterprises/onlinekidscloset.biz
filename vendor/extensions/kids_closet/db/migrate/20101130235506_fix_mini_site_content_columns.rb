class FixMiniSiteContentColumns < ActiveRecord::Migration
  def self.up
    remove_column :sales, :home_content
    remove_column :sales, :about_content
    remove_column :sales, :contact_content
    remove_column :sales, :links_content
    remove_column :sales, :meta_keywords
    remove_column :sales, :meta_description
    remove_column :sales, :locations_and_times_content
    add_column :franchises, :home_content, :text
    add_column :franchises, :about_content, :text
    add_column :franchises, :contact_content, :text
    add_column :franchises, :links_content, :text
    add_column :franchises, :meta_keywords, :text
    add_column :franchises, :meta_description, :text  
    add_column :franchises, :locations_and_times_content, :text
    add_column :franchises, :charity_content, :text
    add_column :franchises, :news_content, :text
  end

  def self.down
    add_column :sales, :home_content, :text
    add_column :sales, :about_content, :text
    add_column :sales, :contact_content, :text
    add_column :sales, :links_content, :text
    add_column :sales, :meta_keywords, :text
    add_column :sales, :meta_description, :text
    add_column :sales, :locations_and_times_content, :text
    remove_column :franchises, :home_content
    remove_column :franchises, :about_content
    remove_column :franchises, :contact_content
    remove_column :franchises, :links_content
    remove_column :franchises, :meta_keywords
    remove_column :franchises, :meta_description
    remove_column :franchises, :locations_and_times_content
    remove_column :franchises, :charity_content
    remove_column :franchises, :news_content
  end
end
