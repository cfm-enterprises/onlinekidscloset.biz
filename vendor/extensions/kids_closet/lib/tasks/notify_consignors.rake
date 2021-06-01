namespace :kids_closet do
  desc "Send email to consignors with items sold online"
  task :notify_consignors => :environment do
    Site.current_site_id = 1
    sale_season = SaleSeason.current_sale_season
    for sale in sale_season.sales
    	if sale.has_online_sale && sale.online_sale_end_date.to_date == Date.today - 1
    		profiles = sale.profiles_with_items_sold_online
        profiles = profiles.uniq
    		for profile in profiles
          email = KidsMailer.create_sale_complete_notification(sale, profile)
          KidsMailer.deliver(email)
    		end
    	end
    end
  end
end
