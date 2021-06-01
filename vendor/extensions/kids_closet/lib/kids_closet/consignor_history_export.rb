module KidsCloset

  class ConsignorHistoryExport < Struct.new(:franchise_id, :email)

    def perform
      Site.current_site_id = 1
      franchise = Franchise.find(franchise_id)
      franchise_profiles = franchise.consignor_profiles
      File.delete(franchise.consignor_history_export_path) if File.exist?(franchise.consignor_history_export_path)
      FasterCSV.open(franchise.consignor_history_export_path, "w") do |csv|
      csv << ['#', 'Sort Group', 'First Name', 'Last Name', 'Email', 'Date Account Created', 'Last Consigned Date', '# Events with Sold Item', 'Lifetime Proceeds', 'Last Sale Proceeds', 'Lifetime Sold Items', 'Last Sale Sold Items', 'Current Unsold Inventory', 'Current Unsold Value', 'Current Inactive Inventory', 'How did you hear?']
        for franchise_profile in franchise_profiles
          csv << [franchise_profile.profile_id, franchise_profile.profile.sort_column, franchise_profile.profile.first_name, franchise_profile.profile.last_name, franchise_profile.profile.email, franchise_profile.created_at.strftime("%B, %d, %Y"), franchise_profile.last_consign_date, franchise_profile.number_of_sales_consigned, sprintf( "$%.02f", franchise_profile.lifetime_total_sold), sprintf( "$%.02f", franchise_profile.last_sale_proceeds), franchise_profile.lifetime_quantity_sold, franchise_profile.last_sale_quantity_sold, franchise_profile.unsold_items, sprintf( "$%.02f", franchise_profile.unsold_items_value), franchise_profile.inactive_items, franchise_profile.profile.how_did_you_hear.nil? ? "N/A" :  (franchise_profile.profile.how_did_you_hear.other ? franchise_profile.profile.how_did_you_hear_other : franchise_profile.profile.how_did_you_hear.label)]
        end
      end
      email_to_deliver = KidsMailer.create_general_mass_email(nil, email, nil, "Consignors History Export",  franchise.consignor_history_export_notification, "", "", "ssmitka@kidscloset.biz")
      KidsMailer.deliver(email_to_deliver)
    end

  end

end