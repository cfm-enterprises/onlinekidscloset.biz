class Franchise < ActiveRecord::Base
  belongs_to :province
  has_many :franchise_photos, :order => "sort_order, id DESC", :dependent => :destroy
  has_many :franchise_slider_photos, :class_name => "FranchisePhoto", :conditions => ["show_in_slider = ?", true], :order => "sort_order ASC, caption ASC", :dependent => :destroy
  has_many :franchise_owner_profiles, :dependent => :destroy
  has_many :owners, :class_name => "Profile", :order => "franchise_owner_profiles.created_at", :through => :franchise_owner_profiles, :source => :profile
  has_many :consignor_profiles, :class_name => "FranchiseProfile", :conditions => {:consignor => true}, :dependent => :destroy
  has_many :new_consignor_franchise_profiles, :class_name => "FranchiseProfile", :conditions => {:new_consignor => true}, :dependent => :destroy
  has_many :consignors, :class_name => "Profile", :order => "last_name, first_name", :through => :consignor_profiles, :source => :profile
  has_many :volunteer_profiles, :class_name => "FranchiseProfile", :conditions => {:volunteer => true}, :dependent => :destroy
  has_many :volunteers, :class_name => "Profile", :order => "last_name, first_name", :through => :volunteer_profiles, :source => :profile
  has_many :mailing_list_member_profiles, :class_name => "FranchiseProfile", :conditions => {:mailing_list => true}, :dependent => :destroy
  has_many :mailing_list_members, :class_name => "Profile", :order => "last_name, first_name", :through => :mailing_list_member_profiles, :source => :profile
  has_many :franchise_profiles
  has_many :bad_email_profiles, :class_name => "FranchiseProfile", :include => :profile, :conditions => ["profiles.bad_email = ?" , true], :order => "profiles.last_name, profiles.first_name"
  has_many :profiles, :order => "last_name, first_name", :through => :franchise_profiles
  has_many :sales, :order => "active desc, start_date desc", :dependent => :destroy
  has_many :kids_emails, :order => "sent_at DESC", :dependent => :destroy
  has_many :franchise_rewards_adjustments, :include => :rewards_profile, :order => "rewards_profiles.rewards_number", :dependent => :destroy
  has_many :adjustment_rewards_profiles, :class_name => "RewardsProfile", :order => "rewards_number", :through => :franchise_rewards_adjustments, :source => :rewards_profile    
  has_many :item_franchise_relationships, :dependent => :destroy
  has_many :items_for_sale_online, :class_name => "ConsignorInventory", :through => :item_franchise_relationships, :order => "consignor_inventories.id DESC", :source => :consignor_inventory
  has_many :franchise_texting_profiles, :dependent => :destroy
  has_one :franchise_content
  has_one :franchise_home_content

  acts_as_site_member

  before_validation :udpate_sale_hash
  after_create :create_franchise_content
  after_save :update_content_columns

  attr_accessor :about_content, :links_content, :charity_content, :incentives_content, :shoppers_info_content, :volunteers_info_content

  validates_uniqueness_of :franchise_name, :case_sensitive => false, :message => "is already in use by another franchise."
  validates_uniqueness_of :sale_hash, :message => " - the franchise name is creating a naming conflict with another franchise."
  validates_presence_of :province_id, :sale_city, :franchise_name, :franchise_email
  validates_length_of :franchise_email, :within => 5..100
  validates_format_of :franchise_email, :with => Bionic::EmailValidation
  validates_format_of :external_email, :with => Bionic::EmailValidation, :allow_blank => true
#  validates_format_of :pay_pal_email, :with => Bionic::EmailValidation, :allow_blank => true

  def self.update_franchises
    franchises = Franchise.find(:all)
    for franchise in franchises
      franchise_content = Franchise seContent.new
      franchise_content.franchise_id = franchise.id
#      franchise_content.about_content = franchise.about_content
      franchise_content.links_content = franchise.links_content
      franchise_content.charity_content = franchise.charity_content
#      franchise_content.incentives_content = franchise.incentives_content
      franchise_content.shoppers_info_content = franchise.shoppers_info_content
      franchise_content.volunteers_info_content = franchise.volunteers_info_content
      franchise_content.save
    end
    return true
  end

  def self.franchises_with_online_sales
    return [3, 77, 85, 83, 86, 87, 84, 88, 89, 90, 91, 92, 93, 94]
  end

  def load_content
#    self.about_content = franchise_content.about_content
    self.links_content = franchise_content.links_content
    self.charity_content = franchise_content.charity_content
#    self.incentives_content = franchise_content.incentives_content
    self.shoppers_info_content = franchise_content.shoppers_info_content
    self.volunteers_info_content = franchise_content.volunteers_info_content
    return true
  end

  def mini_content
    items = []
#    items << ["home_content","Home", home_content]
#    items << ["about_content","About", franchise_content.about_content]
#    items << ["contact_content","Contact", contact_content]
    items << ["links_content","Partners", franchise_content.links_content]
    items << ["locations_and_times_content","Dates and Times", locations_and_times_content]
    items << ["charity_content","Charity", franchise_content.charity_content]
    items << ["news_content","Hidden Landing Page", news_content]
#    items << ["incentives_content", "Incentives", franchise_content.incentives_content]
    items << ["consignors_info_content", "Consignors Info", consignors_info_content]
#    items << ["shoppers_info_content", "Shop Early", franchise_content.shoppers_info_content]
    items << ["volunteers_info_content", "Helpers Info", franchise_content.volunteers_info_content]
    items
  end
  
  def active_sale
    Sale.current_active_sale(self.id)
  end

  def active_sale_id
    Sale.current_active_sale_id(self.id)
  end

  def prior_season_sale
    SaleSeason.prior_season.sales.find(:first, :conditions => ["franchise_id = ?", self.id])
  end

  def second_prior_season_sale
    SaleSeason.second_prior_season.sales.find(:first, :conditions => ["franchise_id = ?", self.id])
  end

  def third_prior_season_sale
    SaleSeason.third_prior_season.sales.find(:first, :conditions => ["franchise_id = ?", self.id])
  end

  def previous_sale
    sales.find(:first, :order => "end_date DESC", :conditions => ["end_date < ?", Date.today])
  end
  
  def number_of_consignors_in_next_sale
    active_sale.number_of_consignors
  end

  def volunteer_job_status
    active_sale.volunteer_jobs_status
  end
  
  def referred_consignors
    consignors.find(:all, :conditions => ["how_did_you_hear_id = ?", 25], :order => "created_at DESC")
  end

  def other_reasons
    franchise_profiles.find(:all, :select => "DISTINCT profiles.how_did_you_hear_other", :include => :profile, :conditions => ["(franchise_profiles.active = ? OR franchise_profiles.mailing_list = ?) AND how_did_you_hear_id = ?", true, true, 26])
  end

  def how_did_you_hear_count(how_did_you_hear_id)
    franchise_profiles.count(:profile_id, :include => :profile, :conditions => ["(franchise_profiles.active = ? OR franchise_profiles.mailing_list = ?) AND how_did_you_hear_id = ?", true, true, how_did_you_hear_id])
  end

  def other_reasons_count(how_did_you_hear_other)
    franchise_profiles.count(:profile_id, :include => :profile, :conditions => ["(franchise_profiles.active = ? OR franchise_profiles.mailing_list = ?) AND how_did_you_hear_other = ?", true, true, how_did_you_hear_other])
  end

  def active_profiles
    profiles.find(:all, :conditions => ["active = ? or mailing_list = ?", true, true])
  end

  def franchise_hash
    franchise_name.downcase.gsub(/[^[:alnum:]]/, '_')
  end  
  
  def rewards_profiles
    primary_profiles = RewardsProfile.find(:all, :conditions => ["profile_id IS NOT NULL AND primary_card = ?", true], :order => "rewards_number")    
    used_rewards_profiles = primary_profiles.delete_if { |rp| !rp.has_rewards_in_franchise(self)}
    un_claimed_profiles = RewardsProfile.find(:all, :select => "DISTINCT rewards_profiles.*", :joins => [:rewards_profile_sale_results, :sales], :conditions => ["franchise_id = ? AND profile_id IS NULL AND rewards_profile_sale_results.amount_purchased >= ?", id, 100], :order => "rewards_number")
    rewards_profiles = used_rewards_profiles + un_claimed_profiles + adjustment_rewards_profiles
    rewards_profiles = rewards_profiles.uniq
    rewards_profiles.sort!{|x,y| x.rewards_number <=> y.rewards_number}
    return rewards_profiles
  end

  def rewards_profiles_search(like_conditions, phrase)
    primary_conditions = ["(#{like_conditions.join(" OR ")})"]
    like_conditions.length.times do
      primary_conditions << "%#{phrase}%"
    end
    adjustment_profiles = adjustment_rewards_profiles.find(:all, :include => :profile, :conditions => primary_conditions)
    primary_profiles = RewardsProfile.find(:all, :include => :profile, :conditions => primary_conditions, :order => "rewards_number")    
    used_rewards_profiles = primary_profiles.delete_if { |rp| !rp.has_rewards_in_franchise(self)}
    un_claimed_profiles = RewardsProfile.find(:all, :select => "DISTINCT rewards_profiles.*", :joins => [:rewards_profile_sale_results, :sales], :conditions => ["franchise_id = ? AND profile_id IS NULL AND rewards_profile_sale_results.amount_purchased >= ? AND rewards_profiles.rewards_number LIKE ?", id, 100, "%#{phrase}%"], :order => "rewards_number")
    rewards_profiles = (used_rewards_profiles + un_claimed_profiles + adjustment_profiles).uniq
    rewards_profiles.sort!{|x,y| x.rewards_number <=> y.rewards_number}
    return rewards_profiles    
  end
  
  def closet_cash_export_path
    "#{RAILS_ROOT}/public/assets/1/#{closet_cash_export_file_name}"
  end

  def closet_cash_export_file_name
    return "franchise_#{id}_rewards.csv"
  end

  def closet_cash_export_notification
    return "Your export file can be downloaded from http://www.kidscloset.biz/assets/1/#{closet_cash_export_file_name}"
  end

  def consignor_history_export_path
    "#{RAILS_ROOT}/public/assets/1/#{consignor_history_export_file_name}"
  end

  def consignor_history_export_file_name
    return "franchise_#{id}_consignors_history_export.csv"
  end

  def consignor_history_export_notification
    return "Your export file can be downloaded from http://www.kidscloset.biz/assets/1/#{consignor_history_export_file_name}"
  end

  def self.check_delayed_jobs
    if DelayedJob.count > 500
      email_to_deliver = KidsMailer.create_general_mass_email(nil, "miguel@recsolutions.com", nil, "DELAYED JOBS STATUS STUCK", "The number of delayed jobs in the database is #{DelayedJob.count}", "", "", "ssmitka@kidscloset.biz")
      KidsMailer.deliver(email_to_deliver)
    end
  end

  def slider_photo_array
    array = []
    photos = franchise_slider_photos
    array << ((photos.count < 1) ? '/assets/1/original/1-2.jpg' : "/assets/1/thumb/#{photos[0].asset_file_name}") 
    array << ((photos.count < 2) ? '/assets/1/original/2-2.jpg' : "/assets/1/thumb/#{photos[1].asset_file_name}") 
    array << ((photos.count < 3) ? '/assets/1/original/3-2.jpg' : "/assets/1/thumb/#{photos[2].asset_file_name}") 
    array << ((photos.count < 4) ? '/assets/1/original/2-2.jpg' : "/assets/1/thumb/#{photos[3].asset_file_name}") 
    array << ((photos.count < 5) ? '/assets/1/original/3-2.jpg' : "/assets/1/thumb/#{photos[4].asset_file_name}") 
    array << ((photos.count < 6) ? '/assets/1/original/1-2.jpg' : "/assets/1/thumb/#{photos[5].asset_file_name}") 
    array << ((photos.count < 7) ? '/assets/1/original/3-2.jpg' : "/assets/1/thumb/#{photos[6].asset_file_name}") 
    array << ((photos.count < 8) ? '/assets/1/original/1-2.jpg' : "/assets/1/thumb/#{photos[7].asset_file_name}") 
    array << ((photos.count < 9) ? '/assets/1/original/2-2.jpg' : "/assets/1/thumb/#{photos[8].asset_file_name}")
    return array
  end

  def send_to_email
    external_email.empty_or_nil? ? franchise_email : external_email 
  end


  protected
    def udpate_sale_hash
      self.sale_hash = self.franchise_hash if !franchise_name.nil?
    end

    def create_francchise_content
      franchise_content = FranchiseContent.new
      franchise_content.franchise_id = self.id
      franchise_content.save
    end

    def update_content_columns
      franchise_content = self.franchise_content
 #     franchise_content.about_content = about_content unless about_content.empty_or_nil?
      franchise_content.links_content = links_content unless links_content.empty_or_nil?
      franchise_content.charity_content = charity_content unless charity_content.empty_or_nil?
 #     franchise_content.incentives_content = incentives_content unless incentives_content.empty_or_nil?
      franchise_content.shoppers_info_content = shoppers_info_content unless shoppers_info_content.empty_or_nil?
      franchise_content.volunteers_info_content = volunteers_info_content unless volunteers_info_content.empty_or_nil?
      franchise_content.save
    end
end
