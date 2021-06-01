class RemoveAcceptTermsAndConditionsFieldToProfile < ActiveRecord::Migration
  def self.up
    remove_column :profiles, :terms_and_conditions
  end

  def self.down
    add_column :profiles, :terms_and_conditions, :boolean, :default => false
  end
end
