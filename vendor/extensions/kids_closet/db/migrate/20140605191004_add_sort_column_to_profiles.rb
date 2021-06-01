class AddSortColumnToProfiles < ActiveRecord::Migration
  def self.up
  	add_column :profiles, :sort_column, :string
  end

  def self.down
  	remove_column :profiles, :sort_column
  end
end
