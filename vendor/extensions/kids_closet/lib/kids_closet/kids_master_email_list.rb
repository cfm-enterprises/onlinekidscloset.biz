module KidsCloset

  class KidsMasterEmailList < Struct.new(:recipients, :email_address)

    def perform
      Site.current_site_id = 1
      kids_email = KidsEmail.new
      kids_email.recipients = recipients
      kids_email.master_email = true
      FasterCSV.open(kids_email.export_path, "w") do |csv|
        csv << ['Email', 'Consignor #', 'Address', 'City', 'State', 'Zip Code', 'First Name', 'Last Name', 'Phone']
        kids_email.email_array.each do |id|
          profile = Profile.find(id)
          if profile.is_subscribed && !profile.bad_email
            address = profile.addresses.find(:first)
            if address.nil?
              csv << [profile.email, profile.id, '', '', '', '', profile.first_name, profile.last_name, profile.phone ]
            else
              csv << [profile.email, profile.id, address.address_line_1, address.city, address.site_province.province.code, address.postal_code, profile.first_name, profile.last_name, profile.phone ]
            end          
          end          
        end
      end
      email = KidsMailer.create_general_mass_email(nil, email_address, nil, "#{kids_email.recipients} CSV File Export", kids_email.export_notification, "", "", "ssmitka@kidscloset.biz")
      KidsMailer.deliver(email)
    end

  end

end