class AdjustTransactionImportToUseAssets < ActiveRecord::Migration
  def self.up
    remove_column :transaction_imports, :report_date
    add_column :transaction_imports, :start_date, :date
    add_column :transaction_imports, :end_date, :date
    add_column :transaction_imports, :processed, :boolean
    add_column :transaction_imports, :site_asset_id, :integer
  end

  def self.down
    add_column :transaction_import, :report_date
    remove_column :transaction_imports, :start_date
    remove_column :transaction_imports, :end_date
    remove_column :transaction_imports, :processed
    remove_column :transaction_imports, :site_asset_id
  end
end
