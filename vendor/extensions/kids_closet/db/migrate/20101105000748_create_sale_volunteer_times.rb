class CreateSaleVolunteerTimes < ActiveRecord::Migration
  def self.up
    create_table :sale_volunteer_times do |t|
      t.integer :sale_id, :number_of_spots
      t.date :date
      t.time :start_time, :end_time
      t.string :job_title
      t.text :job_description
      t.timestamps
    end

    add_index :sale_volunteer_times, [:sale_id, :date, :start_time]
  end
  
  

  def self.down
    drop_table :sale_volunteer_times
  end
end
