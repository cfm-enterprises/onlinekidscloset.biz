class AddNewContentPagesToSales < ActiveRecord::Migration
  def self.up
    add_column :sales, :locations_and_times_content, :text
  end

  def self.down
    remove_column :sales, :locations_and_times_content
  end
end
