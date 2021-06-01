class AddGeocodingColumnsToProfilesAndSales < ActiveRecord::Migration
  def self.up
  	add_column :profiles, :longitude, :float
  	add_column :profiles, :latitude, :float
  	add_column :sales, :longitude, :float
  	add_column :sales, :latitude, :float
  end

  def self.down
  	remove_column :profiles, :longitude
  	remove_column :profiles, :latitude
  	remove_column :sales, :longitude
  	remove_column :sales, :latitude
  end
end
