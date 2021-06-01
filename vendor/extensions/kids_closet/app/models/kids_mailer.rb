class KidsMailer < ActionMailer::Base
  def general_mass_email(franchise, email, profile, subject, html_body, cancel_text, cancel_link, from_email)
    @subject    = subject
    @body["name"] = profile.nil? ? email : "#{profile.first_name} #{profile.last_name}"
    @body["html_body"] = KidsEmail.fix_html_body(html_body)
    @body["subject"] = subject
    @body["franchise_name"] = franchise.nil? ? "Kid's Closet Connection" : franchise.franchise_name 
    @body["franchise_email"] = from_email
    if cancel_link == "http://www.kidscloset.biz/home/unsubscribe_franchise_profile/"
      franchise_profile = profile.franchise_profiles.find(:first, :conditions => ["franchise_id = ?", franchise.id])
      cancel_link += franchise_profile.id.to_s unless franchise_profile.nil?
    end
    @body["cancel_link"] = cancel_link
    @body["cancel_text"] = cancel_text
    @body["unsubscribe_link"] = "http://www.kidscloset.biz/home/unsubscribe_profile/#{profile.id}" unless profile.nil?
    if franchise.nil?
      @body["franchise_phone"] = ""
      @body["facebook_url"] = "https://www.facebook.com/kidsclosetconnection/"
    else
      owner = franchise.owners.find(:first)
      @body["franchise_phone"] = owner.nil? ? "" : owner.phone
      @body["facebook_url"] = franchise.facebook_url.nil? ? "" : franchise.facebook_url
    end
    @recipients = profile.nil? ? email : profile.email
    @from       = "Kid's Closet Connection <#{from_email}>"
    @reply_to   = from_email
    @sent_on    = Time.now
    @headers    = {}
    @headers['Reply-to'] = from_email
  end

  def consignor_confirmation_email(franchise, profile, sale_id)
    @subject    = "Kid's Closet Connection - Consignor Sign Up Confirmation"
    @body["name"] = "#{profile.first_name} #{profile.last_name}"
    @body["subject"] = "Kid's Closet Connection - Consignor Sign Up Confirmation"
    @body["franchise_email"] = "donotreply@kidscloset.biz"
    @body["franchise_name"] = franchise.nil? ? "Kid's Closet Connection" : franchise.franchise_name 
    @body["sale_id"] = sale_id 
    @body["cancel_link"] = "http://www.kidscloset.biz/consignors"
    @body["cancel_text"] = "Cancel Consignment with Kid's Closet Connection."
    @body["unsubscribe_link"] = "http://www.kidscloset.biz/home/unsubscribe_profile/#{profile.id}"
    owner = franchise.owners.find(:first)
    @body["franchise_phone"] = owner.nil? ? "" : owner.phone
    @body["facebook_url"] = franchise.facebook_url.nil? ? "" : franchise.facebook_url
    @recipients = profile.email
    @from       = "Kid's Closet Connection <donotreply@kidscloset.biz>"
    @reply_to   = "donotreply@kidscloset.biz"
    @sent_on    = Time.now
    @headers    = {}
    @headers['Reply-to'] = "donotreply@kidscloset.biz"
  end

  def consignor_online_confirmation_email(sale, profile)
    @subject    = "Kid's Closet Connection - Consignor Sign Up Confirmation"
    @body["name"] = "#{profile.first_name} #{profile.last_name}"
    @body["subject"] = "Kid's Closet Connection - Consignor Sign Up Confirmation"
    @body["franchise_email"] = "donotreply@kidscloset.biz"
    @body["franchise_name"] = sale.franchise.nil? ? "Kid's Closet Connection" : sale.franchise.franchise_name 
    @body["cancel_link"] = "http://www.kidscloset.biz/consignors"
    @body["cancel_text"] = "Cancel Consignment with Kid's Closet Connection."
    @body["sale"] = sale
    @body["unsubscribe_link"] = "http://www.kidscloset.biz/home/unsubscribe_profile/#{profile.id}"
    owner = sale.franchise.owners.find(:first)
    @body["franchise_phone"] = owner.nil? ? "" : owner.phone
    @body["facebook_url"] = sale.franchise.facebook_url.nil? ? "" : sale.franchise.facebook_url
    @recipients = profile.email
    @from       = "Kid's Closet Connection <donotreply@kidscloset.biz>"
    @reply_to   = "donotreply@kidscloset.biz"
    @sent_on    = Time.now
    @headers    = {}
    @headers['Reply-to'] = "donotreply@kidscloset.biz"
  end

  def franchise_owner_notification_email(franchise_profile, subject)
    @subject    = subject
    @body["franchise_profile"] = franchise_profile
    @body["subject"] = subject
    @body["address"] = franchise_profile.profile.addresses.find(:first, :conditions => ["label = ?", 'Main Address'])
    @recipients = franchise_profile.franchise.send_to_email
    @from       = "Kid's Closet Connection System Notification <donotreply@kidscloset.biz>"
    @sent_on    = Time.now
    @headers    = {}
    @headers['Reply-to'] = "ssmitka@kidscloset.biz"
  end

  def franchise_owner_volunteer_notification_email(franchise_profile, job, subject)
    @subject    = subject
    @body["franchise_profile"] = franchise_profile
    @body["job"] = job
    @body["subject"] = subject
    @body["address"] = franchise_profile.profile.addresses.find(:first, :conditions => ["label = ?", 'Main Address'])
    @recipients = franchise_profile.franchise.send_to_email
    @from       = "Kid's Closet Connection System Notification <donotreply@kidscloset.biz>"
    @sent_on    = Time.now
    @headers    = {}
    @headers['Reply-to'] = "ssmitka@kidscloset.biz"
  end

  def purchase_confirmation_email(order)
    @subject    = "KCC - Online Purchase Receipt"
    from_email = order.sale.franchise.franchise_email
    @body["franchise_name"] = order.sale.franchise.franchise_name 
    @body["franchise_email"] = from_email
    owner = order.sale.franchise.owners.find(:first)
    @body["franchise_phone"] = owner.nil? ? "" : owner.phone
    @body["facebook_url"] = order.sale.franchise.facebook_url.nil? ? "" : order.sale.franchise.facebook_url
    @body["order"] = order
    @recipients = order.profile.email
    @from       = "Kid's Closet Connection <#{from_email}>"
    @reply_to   = from_email
    @sent_on    = Time.now
    @headers    = {}
    @headers['Reply-to'] = from_email
  end

  def sale_notification_email(order)
    @subject    = "KCC - Online Sale Notification"
    from_email = order.sale.franchise.franchise_email
    @body["franchise_name"] = order.sale.franchise.franchise_name 
    @body["franchise_email"] = from_email
    owner = order.sale.franchise.owners.find(:first)
    @body["franchise_phone"] = owner.nil? ? "" : owner.phone
    @body["facebook_url"] = order.sale.franchise.facebook_url.nil? ? "" : order.sale.franchise.facebook_url
    @body["order"] = order
    @body["sale_id"] = order.sale.franchise_id
    @recipients = order.seller.email
    @from       = "Kid's Closet Connection <#{from_email}>"
    @reply_to   = from_email
    @sent_on    = Time.now
    @headers    = {}
    @headers['Reply-to'] = from_email
  end

  def sale_complete_notification(sale, seller)
    @subject    = "KCC - Online Sale Completed"
    from_email = sale.franchise.franchise_email
    @body["franchise_name"] = sale.franchise.franchise_name 
    @body["franchise_email"] = from_email
    owner = sale.franchise.owners.find(:first)
    @body["franchise_phone"] = owner.nil? ? "" : owner.phone
    @body["facebook_url"] = sale.franchise.facebook_url.nil? ? "" : sale.franchise.facebook_url
    @body["sale"] = sale
    @body["seller"] = seller
    @recipients = seller.email
    @from       = "Kid's Closet Connection <#{from_email}>"
    @reply_to   = from_email
    @sent_on    = Time.now
    @headers    = {}
    @headers['Reply-to'] = from_email
  end

  def owner_purchase_notification(order)
    @subject    = "KCC - Item Sold Online Notification"
    to_email = order.sale.franchise.send_to_email
    @body["franchise_name"] = order.sale.franchise.franchise_name 
    @body["franchise_email"] = to_email
    owner = order.sale.franchise.owners.find(:first)
    @body["franchise_phone"] = owner.nil? ? "" : owner.phone
    @body["facebook_url"] = order.sale.franchise.facebook_url.nil? ? "" : order.sale.franchise.facebook_url
    @body["order"] = order
    @recipients = to_email
    @from       = "Kid's Closet Connection <ssmitka@kidscloset.biz>"
    @reply_to   = "ssmitka@kidscloset.biz"
    @sent_on    = Time.now
    @headers    = {}
    @headers['Reply-to'] = "ssmitka@kidscloset.biz"
  end
end
