module KidsCloset

  class CreateBarcode < Struct.new(:item_id)

    def perform
      Site.current_site_id = 1
      item = ConsignorInventory.find(:first, :conditions => ["id = ?", item_id])
      if item.not_nil? && !item.status
        ConsignorInventory.create_barcode(item)
      end
    end

  end

end