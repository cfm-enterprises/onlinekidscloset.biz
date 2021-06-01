class CreateKidsMasterEmails < ActiveRecord::Migration
  def self.up
    create_table :kids_master_emails do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :kids_master_emails
  end
end
