class AddPdfFileToSales < ActiveRecord::Migration
  def self.up
    add_column :sales, :sale_pdf_file_name, :string
    add_column :sales, :sale_pdf_file_content_type, :string
    add_column :sales, :sale_pdf_file_size, :string
  end

  def self.down
    remove_column :sales, :sale_pdf_file_name
    remove_column :sales, :sale_pdf_file_content_type
    remove_column :sales, :sale_pdf_file_size    
  end
end
