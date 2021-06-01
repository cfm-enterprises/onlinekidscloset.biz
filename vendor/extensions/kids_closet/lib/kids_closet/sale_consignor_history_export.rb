module KidsCloset

  class SaleConsignorHistoryExport < Struct.new(:sale_id, :email)

    def perform
      Site.current_site_id = 1
      sale = Sale.find(sale_id)
      consignors = sale.consignor_profiles
      File.delete(sale.consignor_history_export_path) if File.exist?(sale.consignor_history_export_path)
      FasterCSV.open(sale.consignor_history_export_path, "w") do |csv|
        csv << ['#', 'Sort Group', 'First Name', 'Last Name', 'Email Address', 'Date Account Created', 'Last Consigned Date', '# Events with Sold Item', 'Lifetime Proceeds', 'Last Sale Proceeds', 'Lifetime Sold Items', 'Last Sale Sold Items', 'Current Unsold Inventory', 'Current Unsold Value', 'Current Inactive Inventory', 'How did you hear?']
        for consignor in consignors
          csv << [consignor.franchise_profile.profile_id, consignor.franchise_profile.profile.sort_column, consignor.franchise_profile.profile.first_name, consignor.franchise_profile.profile.last_name, consignor.franchise_profile.profile.email, consignor.franchise_profile.created_at.strftime("%B, %d, %Y"), consignor.franchise_profile.last_consign_date, consignor.franchise_profile.number_of_sales_consigned, sprintf( "$%.02f", consignor.franchise_profile.lifetime_total_sold), sprintf( "$%.02f", consignor.franchise_profile.last_sale_proceeds(sale_id)), consignor.franchise_profile.lifetime_quantity_sold, consignor.franchise_profile.last_sale_quantity_sold(sale_id), consignor.franchise_profile.unsold_items, sprintf( "$%.02f", consignor.franchise_profile.unsold_items_value), consignor.franchise_profile.inactive_items, consignor.franchise_profile.profile.how_did_you_hear.nil? ? "N/A" : (consignor.franchise_profile.profile.how_did_you_hear.other ? consignor.franchise_profile.profile.how_did_you_hear_other : consignor.franchise_profile.profile.how_did_you_hear.label)]
        end
      end
      email_to_deliver = KidsMailer.create_general_mass_email(nil, email, nil, "Sale Consignors History Export",  sale.consignor_history_export_notification, "", "", "ssmitka@kidscloset.biz")
      KidsMailer.deliver(email_to_deliver)
    end

  end

end