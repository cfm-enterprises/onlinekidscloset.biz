module KidsCloset

  class RemoveBarcode < Struct.new(:item_id)

    def perform
      file_path = "#{RAILS_ROOT}/public/assets/1/barcode_#{item_id}.png"
      File.delete(file_path) if File.exists?(file_path)
    end

  end

end