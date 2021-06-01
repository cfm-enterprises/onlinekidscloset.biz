class CreateSaleSeasons < ActiveRecord::Migration
  def self.up
    create_table :sale_seasons do |t|
      t.date :start_date, :end_date
      t.timestamps
    end
    
    add_index :sale_seasons, :start_date
  end

  def self.down
    drop_table :sale_seasons
  end
end
