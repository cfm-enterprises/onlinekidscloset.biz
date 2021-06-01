class OptionToShowPhotoInSliders < ActiveRecord::Migration
  def self.up
  	add_column :franchise_photos, :show_in_slider, :boolean, :default => false
  end

  def self.down
  end
end
