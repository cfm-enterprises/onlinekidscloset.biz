class KidsEmail < ActiveRecord::Base
  belongs_to :franchise
  has_many :delayed_jobs, :dependent => :destroy

  validates_presence_of :subject, :recipients, :html_body
  validates_presence_of :franchise_id, :if => :require_franchise?

  acts_as_site_member

  named_scope :master_emails, :conditions => ["master_email = ?", true], :order => "sent_at DESC"
  
  def number_of_jobs
    emails = number_of_emails
    jobs = (emails / per_page).to_i
    jobs += 1 if emails.remainder(per_page) > 0
    return jobs
  end

  def status
    return "Draft" if draft_mode
    return "Scheduled for #{send_at.strftime('%b %d, %y %I:%M %p')}" if schedule_email && !send_at.nil? && send_at > Time.now
    return "Sent at #{sent_at.strftime('%A %B %d, %Y %I:%M %p')}"
  end
  
  def number_of_emails
    email_array.length
  end

  def per_page
    schedule_email ? 100000 : 50
  end
      
  def export_file_name
    return "#{self.recipients}_export_list.csv"
  end

  def export_path
    return "#{RAILS_ROOT}/public/assets/1/#{self.export_file_name}"
  end
  
  def export_notification
    return "Your export file can be downloaded from http://www.kidscloset.biz/assets/1/#{export_file_name}"
  end

  def paginated_email_array(page)
    email_array.paginate(:page => page, :per_page => per_page)
  end

  def recipients_array
    recipients = []
    if master_email
      recipients << ["Franchise Owners", "owners"]
      recipients << ["Current Helpers", "volunteers"]
      recipients << ["Past Helpers", "past_volunteers"]
      recipients << ["Current Consignors", "consignors"]
      recipients << ["Consignors with no Tagged", "sleeping_consignors"]
      recipients << ["Past Consignors", "past_consignors"]
      recipients << ["Mailing List", "mailing_list"]
      recipients << ["Everyone", "everyone"]
      recipients << ["Unavailable - Do Not Use", "new_consignors"]
    else
      recipients << ["Current Helpers", "volunteers"]
      recipients << ["Past Helpers", "past_volunteers"]
      recipients << ["Current Consignors", "consignors"]
      recipients << ["Consignors with no Tagged", "sleeping_consignors"]
      recipients << ["Past Consignors", "past_consignors"]
      recipients << ["Mailing List", "mailing_list"]
      recipients << ["Everyone", "everyone"]
      recipients << ["Unavailable - Do Not Use", "new_consignors"]
    end
    return recipients
  end

  def recipient_friendly_name
    recipients_array[recipients_array.index{|recipient| recipient[1]==recipients}][0]
  end

  def email_array
    email_array = []
    if master_email
      if recipients == "consignors"
        sign_ups = SaleConsignorSignUp.find(:all, :select => "DISTINCT franchise_profiles.profile_id", :joins => [:franchise_profile, [:sale_consignor_time => :sale]], :conditions => ["sales.active = ?", true])
        sign_ups.each do |consignor_sign_up|
          email_array << consignor_sign_up.profile_id
        end
      elsif recipients == "sleeping_consignors"
        sign_ups = SaleConsignorSignUp.find(:all, :select => "DISTINCT franchise_profiles.profile_id", :joins => [:franchise_profile, [:sale_consignor_time => :sale]], :conditions => ["sales.active = ?", true])
        sign_ups.each do |consignor_sign_up|
          email_array << consignor_sign_up.profile_id if consignor_sign_up.profile.items_coming == 0
        end
      elsif recipients == "new_consignors"
        profiles = FranchiseProfile.find(:all, :select => "DISTINCT profile_id", :conditions => ["new_consignor = ?", true])
        profiles.each do |profile|
          email_array << profile.profile_id
        end
      elsif recipients == "past_consignors"
        profiles = FranchiseProfile.find(:all, :select => "DISTINCT profile_id", :conditions => ["consignor = ?", true])
        profiles.each do |profile|
          email_array << profile.profile_id
        end
        conflict_array = []
        sign_ups = SaleConsignorSignUp.find(:all, :select => "DISTINCT franchise_profiles.profile_id", :joins => [:franchise_profile, [:sale_consignor_time => :sale]], :conditions => ["sales.active = ?", true])
        sign_ups.each do |consignor_sign_up|
          conflict_array << consignor_sign_up.profile_id.to_i
        end
        email_array = email_array - conflict_array
      elsif recipients == "all_volunteers"
        profiles = FranchiseProfile.find(:all, :select => "DISTINCT profile_id", :conditions => ["volunteer = ?", true])
        profiles.each do |profile|
          email_array << profile.profile_id
        end
      elsif recipients == "volunteers"
        sign_ups = SaleVolunteerSignUp.find(:all, :select => "DISTINCT franchise_profiles.profile_id", :joins => [:franchise_profile, [:sale_volunteer_time => :sale]], :conditions => ["sales.active = ?", true])
        sign_ups.each do |volunteer_sign_up|
          email_array << volunteer_sign_up.profile_id
        end
      elsif recipients == "past_volunteers"
        profiles = FranchiseProfile.find(:all, :select => "DISTINCT profile_id", :conditions => ["volunteer = ?", true])
        profiles.each do |profile|
          email_array << profile.profile_id
        end
        conflict_array = []
        sign_ups = SaleVolunteerSignUp.find(:all, :select => "DISTINCT franchise_profiles.profile_id", :joins => [:franchise_profile, [:sale_volunteer_time => :sale]], :conditions => ["sales.active = ?", true])
        sign_ups.each do |volunteer_sign_up|
          conflict_array << volunteer_sign_up.profile_id.to_i
        end
        email_array = email_array - conflict_array
      elsif recipients == "rewards"
        profiles = RewardsProfile.find(:all, :select => "DISTINCT profile_id", :conditions => "profile_id IS NOT NULL")
        profiles.each do |profile|
          email_array << profile.profile_id if profile.profile.is_subscribed
        end
      elsif recipients == "mailing_list"
        Profile.find(:all, :conditions => ["is_subscribed = ?", true]).each do |profile|
          email_array << profile.id
        end
      elsif recipients == "owners"
        profiles = FranchiseOwnerProfile.find(:all, :select => "DISTINCT profile_id")
        profiles.each do |profile|
          email_array << profile.profile_id
        end
      elsif recipients == "everyone"
        #consignors/volunteers
        profiles = FranchiseProfile.find(:all, :conditions => ["active = ?", true]).each do |profile|
          email_array << profile.profile_id
        end
        #rewards members
#        profiles = RewardsProfile.find(:all, :select => "DISTINCT profile_id", :conditions => "profile_id IS NOT NULL")
#        profiles.each do |profile|
#          email_array << profile.profile_id if profile.profile.is_subscribed
#        end
        #franchise_owners
        profiles = FranchiseOwnerProfile.find(:all, :select => "DISTINCT profile_id")
        profiles.each do |profile|
          email_array << profile.profile_id
        end
        #kids mailing list
        Profile.find(:all, :conditions => ["is_subscribed = ?", true]).each do |profile|
          email_array << profile.id
        end
        email_array.uniq! unless email_array.empty?
      end
    else
      if recipients == "consignors"
        unless franchise.active_sale.nil?
          franchise.active_sale.consignor_profiles.each do |profile|
            email_array << profile.franchise_profile.profile_id
          end
        end
      elsif recipients == "sleeping_consignors"
        unless franchise.active_sale.nil?
          franchise.active_sale.consignor_profiles.each do |profile|
            email_array << profile.franchise_profile.profile_id if profile.franchise_profile.profile.items_coming == 0
          end
        end
      elsif recipients == "new_consignors"
        franchise.new_consignor_franchise_profiles.each do |franchise_profile|
          email_array << franchise_profile.profile_id
        end
      elsif recipients == "past_consignors"
        profiles = franchise.consignors
        profiles.each do |profile|
          email_array << profile.id
        end
        conflict_array = []
        unless franchise.active_sale.nil?
          franchise.active_sale.consignor_profiles.each do |profile|
            conflict_array << profile.franchise_profile.profile_id
          end
        end
        email_array = email_array - conflict_array
      elsif recipients == "all_volunteers"
        profiles = franchise.volunteers
        profiles.each do |profile|
          email_array << profile.id
        end
      elsif recipients == "volunteers"
        unless franchise.active_sale.nil?
          franchise.active_sale.volunteer_profiles.each do |profile|
            email_array << profile.franchise_profile.profile_id
          end
          email_array.uniq! unless email_array.empty?
        end
      elsif recipients == "past_volunteers"
        profiles = franchise.volunteers
        profiles.each do |profile|
          email_array << profile.id
        end
        conflict_array = []
        unless franchise.active_sale.nil?
          franchise.active_sale.volunteer_profiles.each do |profile|
            conflict_array << profile.franchise_profile.profile_id
          end
        end
        email_array = email_array - conflict_array
 #     elsif recipients == "rewards"
 #       franchise.sales.each do |sale|
 #         rewards_profiles = sale.rewards_profile_sale_results
 #         rewards_profiles.each do |rewards_profile_result|
 #           email_array << rewards_profile_result.rewards_profile.profile_id unless rewards_profile_result.rewards_profile.profile.nil?
 #         end
 #       end      
 #       email_array.uniq! unless email_array.empty?
      elsif recipients == "mailing_list"
        franchise.mailing_list_members.each do |profile|
           email_array << profile.id
        end
      elsif recipients == "everyone"
        franchise.franchise_profiles.find(:all, :conditions => ["active = ? OR mailing_list = ?", true, true]).each do |profile|
          email_array << profile.profile_id
        end
 #       franchise.sales.each do |sale|
 #         rewards_profiles = sale.rewards_profile_sale_results
 #         rewards_profiles.each do |rewards_profile_result|
 #           email_array << rewards_profile_result.rewards_profile.profile_id unless rewards_profile_result.rewards_profile.profile.nil?
 #         end
 #       end      
        email_array.uniq! unless email_array.empty?
      end
    end
    return email_array
  end

  def cancel_texts
    if recipients == "consignors"
      cancel_text = "Cancel Consignment and Stop Emails"
      cancel_link = "http://www.kidscloset.biz/consignors"
    elsif recipients == "past_consignors"
      cancel_text = "Cancel Consignment with Kids Closet Connection"
      cancel_link = "http://www.kidscloset.biz/consignors"
    elsif recipients == "volunteers"
      cancel_text = "Cancel Helping with Kids Closet Connection"
      cancel_link = "http://www.kidscloset.biz/consignors"
    elsif recipients == "rewards"
      cancel_text = ""
      cancel_link = ""
    elsif recipients == "mailing_list"
      franchise = franchise = Franchise.find(franchise_id)
      cancel_text = "Remove me from the #{franchise.franchise_name} mailing list."
      cancel_link = "http://www.kidscloset.biz/home/unsubscribe_franchise_profile/"
    elsif recipients == "everyone"
      cancel_text = "special"
      cancel_link = "http://www.kidscloset.biz/home/unsubscribe_franchise_profile/"
    end
    return cancel_text, cancel_link      
  end

  def self.fix_html_body(body)
    html_body = body.gsub("src=\"/assets", "src=\"http://www.kidscloset.biz/assets")
  end

  protected

  def require_franchise?
    !master_email
  end
end
