class CreateSaleConsignorTimes < ActiveRecord::Migration
  def self.up
    create_table :sale_consignor_times do |t|
      t.integer :sale_id, :number_of_spots
      t.date :date
      t.time :start_time, :end_time
      t.timestamps
    end

    add_index :sale_consignor_times, [:sale_id, :date, :start_time]
  end


  def self.down
    drop_table :sale_consignor_times
  end
end
