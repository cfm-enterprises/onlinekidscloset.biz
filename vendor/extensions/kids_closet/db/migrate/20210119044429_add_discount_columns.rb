class AddDiscountColumns < ActiveRecord::Migration
  def self.up
  	add_column :sales, :first_discount_start_time, :datetime
  	add_column :sales, :second_discount_start_time, :datetime
  end

  def self.down
  end
end
