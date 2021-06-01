class AddSortOrdersToSliderImages < ActiveRecord::Migration
  def self.up
  	add_column :franchise_photos, :sort_order, :decimal, :precision => 6, :scale => 2, :default => 1
  	change_column :franchise_photos, :show_in_slider, :boolean, :default => true
  end

  def self.down
  	remove_column :franchise_photos, :sort_order
  	change_column :franchise_photos, :show_in_slider, :boolean, :default => false
  end
end
