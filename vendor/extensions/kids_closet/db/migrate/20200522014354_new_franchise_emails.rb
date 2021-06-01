class NewFranchiseEmails < ActiveRecord::Migration
  def self.up
  	add_column :franchises, :pay_pal_email, :string
  	add_column :franchises, :external_email, :string
  end

  def self.down
  end
end
