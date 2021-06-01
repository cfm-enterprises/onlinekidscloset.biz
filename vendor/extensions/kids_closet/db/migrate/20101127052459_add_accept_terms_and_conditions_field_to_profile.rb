class AddAcceptTermsAndConditionsFieldToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :terms_and_conditions, :boolean, :default => false
  end

  def self.down
    remove_column :profiles, :terms_and_conditions
  end
end
