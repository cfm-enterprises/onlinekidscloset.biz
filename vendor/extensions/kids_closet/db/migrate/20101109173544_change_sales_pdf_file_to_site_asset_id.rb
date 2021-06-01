class ChangeSalesPdfFileToSiteAssetId < ActiveRecord::Migration
  def self.up
    remove_column :sales, :sale_pdf_file_name
    remove_column :sales, :sale_pdf_file_content_type
    remove_column :sales, :sale_pdf_file_size    
    add_column :sales, :site_asset_id, :integer
  end

  def self.down
    add_column :sales, :sale_pdf_file_name, :string
    add_column :sales, :sale_pdf_file_content_type, :string
    add_column :sales, :sale_pdf_file_size, :string
    remove_column :sales, :site_asset_id
  end
end
