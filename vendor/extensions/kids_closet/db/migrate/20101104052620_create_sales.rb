class CreateSales < ActiveRecord::Migration
  def self.up
    create_table :sales do |t|
      t.integer :franchise_id
      t.string :sale_address, :sale_address2
      t.decimal :sale_percentage, :precision => 6, :scale => 2, :default => 0
      t.decimal :sale_advert_cost, :precision => 6, :scale => 2, :default => 0
      t.date :start_date, :end_date
      t.text :home_content, :about_content, :contact_content, :links_content
      t.text :meta_keywords, :meta_description 
      t.timestamps
    end

    add_index :sales, :franchise_id
  end

  

  def self.down
    drop_table :sales
  end
end
