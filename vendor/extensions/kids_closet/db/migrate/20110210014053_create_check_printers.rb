class CreateCheckPrinters < ActiveRecord::Migration
  def self.up
    create_table :check_printers do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :check_printers
  end
end
