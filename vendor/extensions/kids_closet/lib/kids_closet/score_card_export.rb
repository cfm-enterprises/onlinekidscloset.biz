module KidsCloset

  class ScoreCardExport < Struct.new(:admin, :profile_id, :email)

    def perform
      Site.current_site_id = 1

      if admin.to_s == "true"
        franchises = Franchise.find(:all, :include => :province, :order => "franchise_name")
      else
        franchise_owner_profiles = Profile.find(profile_id.to_i).franchise_owner_profiles
        franchises = Franchise.find(:all, :include => :province, :order => "franchise_name", :conditions => ["id in (?)", franchise_owner_profiles.empty? ? 0 : franchise_owner_profiles.map(&:franchise_id)])
      end
      
      FasterCSV.open(FranchiseOwnerProfile.score_card_export_path(profile_id), "w") do |csv|
        csv << ['', '', '', 'Upcoming Sale', '', '', 
              'Total Sold', '', '', 
              '# Items Coming to Sale', '', '', 
              '# Items Sold', '', '', 
              '# Trans', '', '', 
              '# Cons w/ Sold Items', '', '', 
              '# Signed Up Consignors', '', '']
        csv << ['Franchise Name', 'Date', 'Days Until Sale', 'Consignor Count', 'Helper Count', '# Items Tagged', '3rd Prior', '2nd Prior', '1st Prior', '3rd Prior', '2nd Prior', '1st Prior', '3rd Prior', '2nd Prior', '1st Prior', '3rd Prior', '2nd Prior', '1st Prior', '3rd Prior', '2nd Prior', '1st Prior', '3rd Prior', '2nd Prior', '1st Prior']
        for franchise in franchises
          csv << [franchise.franchise_name, franchise.active_sale.nil? ? "N/A" : franchise.active_sale.start_date.strftime("%B %d, %Y"), 
            franchise.active_sale.nil? ? "N/A" : franchise.active_sale.days_until_sale, 
            franchise.active_sale.nil? ? "N/A" : franchise.active_sale.number_of_consignors, 
            franchise.active_sale.nil? ? "N/A" : franchise.active_sale.number_of_volunteers, 
            franchise.active_sale.nil? ? "N/A" : franchise.active_sale.number_of_possible_sale_items,
           franchise.third_prior_season_sale.nil? ? "N/A" : franchise.third_prior_season_sale.total_amount_sold, franchise.second_prior_season_sale.nil? ? "N/A" : franchise.second_prior_season_sale.total_amount_sold, franchise.prior_season_sale.nil? ? "N/A" : franchise.prior_season_sale.total_amount_sold,
           franchise.third_prior_season_sale.nil? ? "N/A" : franchise.third_prior_season_sale.items_coming, franchise.second_prior_season_sale.nil? ? "N/A" : franchise.second_prior_season_sale.items_coming, franchise.prior_season_sale.nil? ? "N/A" : franchise.prior_season_sale.items_coming, 
           franchise.third_prior_season_sale.nil? ? "N/A" : franchise.third_prior_season_sale.total_items_sold, franchise.second_prior_season_sale.nil? ? "N/A" : franchise.second_prior_season_sale.total_items_sold, franchise.prior_season_sale.nil? ? "N/A" : franchise.prior_season_sale.total_items_sold, 
           franchise.third_prior_season_sale.nil? ? "N/A" : franchise.third_prior_season_sale.transaction_count, franchise.second_prior_season_sale.nil? ? "N/A" : franchise.second_prior_season_sale.transaction_count, franchise.prior_season_sale.nil? ? "N/A" : franchise.prior_season_sale.transaction_count, 
           franchise.third_prior_season_sale.nil? ? "N/A" : franchise.third_prior_season_sale.calculate_consignors_that_sold_items, franchise.second_prior_season_sale.nil? ? "N/A" : franchise.second_prior_season_sale.calculate_consignors_that_sold_items, franchise.prior_season_sale.nil? ? "N/A" : franchise.prior_season_sale.calculate_consignors_that_sold_items, 
           franchise.third_prior_season_sale.nil? ? "N/A" : franchise.third_prior_season_sale.number_of_consignors, franchise.second_prior_season_sale.nil? ? "N/A" : franchise.second_prior_season_sale.number_of_consignors, franchise.prior_season_sale.nil? ? "N/A" : franchise.prior_season_sale.number_of_consignors]
        end
      end
      email_to_deliver = KidsMailer.create_general_mass_email(nil, email, nil, "Score Card Export",  FranchiseOwnerProfile.score_card_export_notification(profile_id), "", "", "ssmitka@kidscloset.biz")
      KidsMailer.deliver(email_to_deliver)
    end

  end

end