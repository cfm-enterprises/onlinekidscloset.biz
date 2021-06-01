module KidsCloset

  class KidsEmailSender < Struct.new(:franchise_id, :recipients, :subject, :schedule_email, :page, :text_body, :html_body)

    def perform
      Site.current_site_id = 1
      kids_email = KidsEmail.new
      kids_email.franchise_id = franchise_id
      kids_email.recipients = recipients
      kids_email.schedule_email = (schedule_email == "true")
      franchise = Franchise.find(franchise_id)
      cancel_text, cancel_link = kids_email.cancel_texts
      kids_email.paginated_email_array(page).each do |id|
        profile = Profile.find(id)
        if profile.is_subscribed && !profile.bad_email
          email = KidsMailer.create_general_mass_email(franchise, nil, profile, subject, html_body, cancel_text, cancel_link, franchise.franchise_email)
    	    KidsMailer.deliver(email)			                    
    	  end
      end
      if recipients == "new_consignors" && page == kids_email.number_of_jobs
        franchise.new_consignor_franchise_profiles.each do |franchise_profile|
          franchise_profile.new_consignor = false
          franchise_profile.save
        end
      end         
    end

  end

end