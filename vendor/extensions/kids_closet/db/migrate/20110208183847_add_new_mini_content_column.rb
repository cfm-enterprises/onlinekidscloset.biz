class AddNewMiniContentColumn < ActiveRecord::Migration
  def self.up
    add_column :franchises, :incentives_content, :text
  end

  def self.down
    remove_column :franchises, :incentives_content
  end
end
