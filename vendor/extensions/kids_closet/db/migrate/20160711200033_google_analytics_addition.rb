class GoogleAnalyticsAddition < ActiveRecord::Migration
  def self.up
  	add_column :franchises, :google_analytics_code, :string
  end

  def self.down
  	remove_column :franchises, :google_analytics_code
  end
end
