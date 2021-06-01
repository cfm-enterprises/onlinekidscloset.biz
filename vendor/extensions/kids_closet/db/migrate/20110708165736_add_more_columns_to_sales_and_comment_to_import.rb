class AddMoreColumnsToSalesAndCommentToImport < ActiveRecord::Migration
  def self.up
    add_column :transaction_imports, :status, :string, :default => "Complete"
  end

  def self.down
    remove_column :transaction_imports, :status
  end
end
