class CreateFranchiseContents < ActiveRecord::Migration
  def self.up
    create_table :franchise_contents do |t|
    	t.integer :franchise_id
    	t.text :about_content, :links_content, :charity_content, :incentives_content, :shoppers_info_content, :volunteers_info_content
      t.timestamps
    end
  end

  def self.down
    drop_table :franchise_contents
  end
end
