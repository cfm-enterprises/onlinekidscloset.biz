class CreateTransactionImports < ActiveRecord::Migration
  def self.up
    create_table :transaction_imports do |t|
      t.integer :sale_id
      t.string :report_file_name
      t.date :report_date
      t.decimal :extra_income, :precision => 6, :scale => 2
      t.timestamps
    end

    add_index :transaction_imports, :sale_id
  end

  def self.down
    drop_table :rewards_earnings
  end
end  