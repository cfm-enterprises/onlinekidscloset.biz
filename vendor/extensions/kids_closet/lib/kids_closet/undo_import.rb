module KidsCloset

  class UndoImport < Struct.new(:transaction_import_id)

    def perform
      Site.current_site_id = 1
      @transaction_import = TransactionImport.find(transaction_import_id)
      @transaction_import.status = "Removing Transactions"
      @transaction_import.save
      TransactionImport.transaction do
        #delete items added by import
        delete_import_items(true)
  
        #roll back if needed
        do_rollback if @transaction_import.processed
      end
      @transaction_import.status = "Recalculating Financials"
      @transaction_import.save
      @transaction_import.sale.calculate_financials
      @transaction_import.status = "Deleting Files"
      @transaction_import.save
      TransactionImport.transaction do
        @site_asset = @transaction_import.site_asset
        @site_asset.destroy unless @site_asset.nil?
        @transaction_import.destroy
      end
    rescue ActiveRecord::RecordInvalid => e
      @transaction_import.status = "Could not delete the import file. #{e.record.errors.full_messages.join(", ")}"
      @transaction_import.save
    end

    def do_rollback
      items_sold = @transaction_import.items_sold
      for item in items_sold
        item.transaction_import_id = nil
        item.sale_id = nil
        item.discounted_at_sale = nil
        item.sale_price = nil
        item.tax_collected = nil
        item.total_price = nil
        item.sale_date = nil
        item.transaction_number = nil
        item.import_error_comment = nil
        item.rewards_profile_id = nil
        item.status = false
        item.save!      
      end
    end      

    def delete_import_items(full_delete)
      conditions = ["item_description = ?", "Unscannable Item-Added by System ##{@transaction_import.id}"] 
      items_sold = ConsignorInventory.find(:all, :conditions => conditions)
      for item in items_sold
        item.destroy
      end
    end

  end
end