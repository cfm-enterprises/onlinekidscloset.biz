class AdjustMoreDefaultValues < ActiveRecord::Migration
  def self.up
    change_column :transaction_imports, :extra_income, :decimal, :precision => 6, :scale => 2, :default => 0
  end

  def self.down
  end
end
