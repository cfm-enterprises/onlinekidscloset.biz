module KidsCloset

  class KidsMasterEmailSender < Struct.new(:recipients, :subject, :schedule_email, :page, :sender, :text_body, :html_body)

    def perform
      Site.current_site_id = 1
      kids_email = KidsEmail.new
      kids_email.recipients = recipients
      kids_email.master_email = true
      kids_email.schedule_email = (schedule_email == "true")
      kids_email.paginated_email_array(page).each do |id|
        profile = Profile.find(id)
        if (profile.is_subscribed && !profile.bad_email) || recipients == "owners"
          email = KidsMailer.create_general_mass_email(nil, nil, profile, subject, html_body, "", "", sender)
    	    KidsMailer.deliver(email)
    	  end
      end
   
    end

  end

end