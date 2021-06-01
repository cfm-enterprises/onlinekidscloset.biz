module KidsCloset

  class ItemsComingExport < Struct.new(:sale_id, :item_id, :item_name, :profile_id, :consignor_search, :size, :email)

    def perform
      Site.current_site_id = 1
      sale = Sale.find(sale_id)
      if item_id || item_name || profile_id || consignor_search || size
        conditions = ConsignorInventory.build_items_coming_quick_conditions(item_id, item_name, size, false, "")
        profile = Profile.find(profile_id) unless profile_id.blank?
        profile = Profile.find(consignor_search) unless consignor_search.blank?
        items_coming = sale.possible_sale_items_search(profile, conditions)
      else
        items_coming = sale.possible_sale_items
      end
      FasterCSV.open(sale.items_coming_export_path, "w") do |csv|
        csv << ['Consignor #', 'Consignor Name', 'Sort Column', 'INVENTORY ID #', 'Description', 'Size', 'Price', 'Discount', 'Donate', 'Featured']
        total_available = 0
        for item in items_coming
          csv << [item.profile_id, item.profile.full_name, item.profile.sort_column, item.id, item.item_description, item.size, "$#{item.price}", item.last_day_discount ? "Yes" : "No", item.donate ? "Yes" : "No", item.featured_item ? "Yes" : "No"]
        end
        csv << ['Total Items Coming to Sale: ', "", "", "", "#{items_coming.length}"]
      end
      email_to_send = KidsMailer.create_general_mass_email(nil, email, nil, "Items Coming to Sale Export", sale.items_coming_export_notification, "", "", "ssmitka@kidscloset.biz")
      KidsMailer.deliver(email_to_send)
    end

  end

end