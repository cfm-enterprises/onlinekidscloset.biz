class Sale < ActiveRecord::Base

  belongs_to :franchise
  belongs_to :site_asset
  belongs_to :sale_season
  has_many :sale_consignor_times, :order => "date, start_time", :dependent => :destroy
  has_many :consignor_profiles, :class_name => "SaleConsignorSignUp", :through => :sale_consignor_times, :include => [:franchise_profile => :profile], :order => "profiles.last_name, profiles.first_name", :source => :sale_consignor_sign_ups
  has_many :sale_volunteer_times, :dependent => :destroy
  has_many :active_volunteer_jobs, :class_name => "SaleVolunteerTime", :conditions => ["draft_status = ?", false], :dependent => :destroy
  has_many :draft_volunteer_jobs, :class_name => "SaleVolunteerTime", :conditions => ["draft_status = ?", true], :dependent => :destroy
  has_many :volunteer_profiles, :class_name => "SaleVolunteerSignUp", :through => :sale_volunteer_times, :include => [:franchise_profile => :profile], :order => "profiles.last_name, profiles.first_name", :source => :sale_volunteer_sign_ups
  has_many :rewards_earnings, :dependent => :nullify, :include => :rewards_profile, :order => "rewards_profiles.rewards_number, rewards_earnings.created_at"
  has_many :items_sold, :class_name => "ConsignorInventory", :foreign_key => "sale_id", :dependent => :nullify
  has_many :transaction_imports, :order => "report_date"
  has_many :rewards_imports, :order => "rewards_date"
  has_many :rewards_profile_sale_results, :dependent => :destroy
  has_many :reward_profiles, :through => :reward_profile_sale_results, :include => :profile, :order => "reward_profiles.rewards_number"
  has_many :business_partners, :order => "sort_index ASC, partner_title ASC", :dependent => :destroy 
  has_many :orders, :conditions => "purchased_at IS NOT NULL", :order => "buyer_id"
  has_many :buyers, :class_name => "Profile", :through => :orders, :order => "profiles.last_name, profiles.first_name", :foreign_key => :buyer_id, :source => :buyer
  has_many :profiles_with_items_sold_online, :class_name => "Profile", :through => :orders, :foreign_key => :seller_id, :source => :seller
  has_many :pay_pal_orders, :dependent => :nullify  
  has_many :expired_pay_pal_orders, :class_name => "PayPalOrder", :conditions => ["ordered_at < ? AND purchased_at IS NULL", Time.now.utc - 15 * 60]
  acts_as_site_member
  geocoded_by :geocode_address

  attr_accessor :previous_sale_percentage

  before_validation :identify_and_assign_sale_season
  after_validation :create_geocode          # auto-fetch coordinates
  before_save :set_previous_sale_percentage
  before_save :inactivate_old_sale_if_active
  after_create :add_internal_consignor_time
  after_update :update_consignors_with_new_percentage
  
  validates_presence_of :sale_season_id, :message => "We do not have a sale season assigned for the dates of your sale."
  validates_presence_of :facility_name
  validates_length_of :facility_name, :maximum  => 45, :message => " must be smaller than 45 characters"
  validates_numericality_of :sale_percentage, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100
  validates_numericality_of :sale_advert_cost, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 15
  validates_inclusion_of :sale_percentage, :in => [65.0, 70.0, 75.0, 80.0]
  validates_uniqueness_of :sale_season_id, :scope => :franchise_id, :message => "You already have a sale for the desired sale season."
  validates_numericality_of :tax_rate, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 20, :if => :has_online_sale

  named_scope :geocoded, lambda {{:conditions => "latitude IS NOT NULL AND longitude IS NOT NULL"}}
  named_scope :not_geocoded, lambda {{:conditions => "latitude IS NULL OR longitude IS NULL"}}
  named_scope :active_sales, lambda {{:conditions => ["active = ?", true]}}
  named_scope :near, lambda{ |location, *args|
          latitude, longitude = location.is_a?(Array) ?
            location : Geocoder.coordinates(location)
          if latitude and longitude
            near_scope_options(latitude, longitude, *args)
          else
            {}
          end
        }

  def validate
    errors.add(:end_date, " Must be greater than the Start Date") if end_date < start_date
    if has_online_sale
      errors.add(:online_sale_end_date, " Must be after the Online Sale Start Time") if online_sale_end_date.nil? || online_sale_start_date.nil? || online_sale_end_date < online_sale_start_date      
      errors.add(:first_discount_start_time, " Must be after the Online Sale Start Time") if first_discount_start_time.nil? || online_sale_start_date.nil? || first_discount_start_time < online_sale_start_date      
      errors.add(:first_discount_start_time, " Must be before the Online Sale End Time") if first_discount_start_time.nil? || online_sale_end_date.nil? || first_discount_start_time > online_sale_end_date      
      errors.add(:second_discount_start_time, " Must be after the 25 Percent Discount Start Time") if second_discount_start_time.nil? || online_sale_start_date.nil? || second_discount_start_time < first_discount_start_time      
      errors.add(:second_discount_start_time, " Must be before the Online Sale End Time") if second_discount_start_time.nil? || online_sale_end_date.nil? || second_discount_start_time > online_sale_end_date      
    end
  end
  
  def sale_dates
    self.tentative_date.blank? ? "#{self.start_date.strftime("%B %d, %Y")} - #{self.end_date.strftime("%B %d, %Y")}" : self.tentative_date
  end

  def online_sale_dates
    if [20, 42, 30, 19, 51, 17].include?(franchise.province_id)
      "#{(self.online_sale_start_date - 3600).strftime("%B %d, %Y")} - #{(self.online_sale_end_date - 3600).strftime("%B %d, %Y")}"
    elsif [2].include?(franchise.province_id)
      "#{(self.online_sale_start_date - 14400).strftime("%B %d, %Y")} - #{(self.online_sale_end_date - 14400).strftime("%B %d, %Y")}"
    elsif [4].include?(franchise.province_id)
      "#{(self.online_sale_start_date - 7200).strftime("%B %d, %Y")} - #{(self.online_sale_end_date - 7200).strftime("%B %d, %Y")}"
    else
      "#{self.online_sale_start_date.strftime("%B %d, %Y")} - #{self.online_sale_end_date.strftime("%B %d, %Y")}"
    end
  end

  def adjusted_online_sale_start_date
    if [20, 42, 30, 19, 51, 17].include?(franchise.province_id)
      online_sale_start_date - 3600
    elsif [2].include?(franchise.province_id)
      online_sale_start_date - 14400
    elsif [4].include?(franchise.province_id)
      online_sale_start_date - 7200
    else
      online_sale_start_date
    end
  end

  def adjusted_online_sale_end_date
    if [20, 42, 30, 19, 51, 17].include?(franchise.province_id)
      online_sale_end_date - 3600
    elsif [2].include?(franchise.province_id)
      online_sale_end_date - 14400
    elsif [4].include?(franchise.province_id)
      online_sale_end_date - 7200
    else
      online_sale_end_date
    end
  end

  def is_on_last_day_of_sale?
    if has_online_sale?
      return false unless allow_online_discount
      ((online_sale_end_date - 24 * 60 * 60) <= Time.now) && (online_sale_end_date >= Time.now) 
    else
      end_date == Date.today
    end
  end

  def is_on_25_percent_discount?
    if has_online_sale?
      (first_discount_start_time <= Time.now) && (second_discount_start_time >= Time.now) 
    else
      false
    end
  end

  def is_on_50_percent_discount?
    if has_online_sale?
      (second_discount_start_time <= Time.now) && (online_sale_end_date >= Time.now) 
    else
      false
    end
  end

  def has_online_orders
    !orders.empty?
  end

  def days_until_sale
    return "TBA" unless tentative_date.blank?
    return start_date - Date.today 
  end

  def pdf_dates
    self.tentative_date.blank? ? "#{self.start_date.strftime("%B %d")} #{self.start_date.month == self.end_date.month ? self.end_date.strftime("- %d, %Y") : self.end_date.strftime("- %B %d, %Y")}" : self.tentative_date
  end

  def sale_title
    self.franchise.franchise_name
  end

  def calculate_number_of_items_sold
    self.items_sold.count
  end
  
  def calculate_total_sold
    self.items_sold.sum(:sale_price)
  end
  
  def calculate_tax_collected
    self.items_sold.sum(:tax_collected)
  end

  def calculate_total_collected
    self.total_amount_sold + self.tax_received
  end
  
  def calculate_percent_fees_collected
    self.consignor_profiles.sum(:percentage_fee_paid)    
  end
  
  def calculate_advertisement_fees_collected
    self.consignor_profiles.sum(:advertisement_fee_paid)    
  end
  
  def calculate_gross_revenue
    self.total_amount_sold + self.extra_income + self.calculate_advertisement_fees_collected
  end 
  
  def calculate_total_revenue
    self.calculate_total_collected + self.extra_income
  end

  def calculate_gross_profit
    self.calculate_percent_fees_collected + self.extra_income + self.calculate_advertisement_fees_collected
  end
  
  def calculate_royalty_fee
    base_amount = (self.total_amount_sold + self.extra_income + self.calculate_advertisement_fees_collected)
    if base_amount < 50000
      royalty = base_amount * 0.03
      royalty = 500 if royalty < 500 && franchise.use_minimum_royalty
    elsif base_amount < 100000
      royalty = 1500 + (base_amount - 50000) * 0.02
    else
      royalty = 2500 + (base_amount - 100000) * 0.01
    end
    return royalty
  end
  
  def calculate_net_profit
    self.calculate_gross_profit - self.calculate_royalty_fee
  end

  def number_of_consignors
    self.consignor_profiles.count
  end

  def rewards_applied
    self.rewards_earnings.sum(:amount_applied)
  end

  def unique_volunteers
    volunteer_profiles = self.volunteer_profiles
    if volunteer_profiles.empty? 
      return []
    else
      franchise_profile_id_numbers = []
      volunteer_profiles.each do |volunteer_profile|
        franchise_profile_id_numbers << volunteer_profile.franchise_profile_id
      end
      franchise_profile_id_numbers.uniq!
      FranchiseProfile.find(:all, :include => :profile, :order => "profiles.last_name, profiles.first_name", :conditions => ["franchise_profiles.id in (#{franchise_profile_id_numbers.join(", ")})"])
    end
  end

  def number_of_volunteers
    self.unique_volunteers.count
  end
  
  def calculate_consignors_that_sold_items
    self.consignor_profiles.count(:profile_id, :conditions =>  ["quantity_sold > ?", 0])
  end

  def calculate_number_of_transactions
    counts = self.items_sold.count(:transaction_number, :distinct => true, :group => :transaction_import_id)
    total = 0
    for count in counts
      total += count[1]
    end
    return total
  end
  
  def extra_income
    self.transaction_imports.sum(:extra_income)
  end
  
  def reward_profile_ids
    items_sold.find(:all, :order => "rewards_profile_id", :select => "DISTINCT rewards_profile_id", :conditions => "rewards_profile_id IS NOT NULL").map(&:rewards_profile_id)
  end
  
  def primary_reward_profile_ids
    items_sold.find(:all, :joins => :rewards_profile, :order => "rewards_profile_id", :select => "DISTINCT rewards_profile_id", :conditions => ["rewards_profile_id IS NOT NULL AND (rewards_profiles.profile_id IS NULL OR rewards_profiles.primary_card = ?)", true]).map(&:rewards_profile_id)
  end
  
  def amount_purchased_by_rewards_profile(reward_profile_id)
    reward_result = rewards_profile_sale_results.find(:first, :conditions => ["rewards_profile_id = ?", reward_profile_id])
    return reward_result.nil? ? 0 : reward_result.amount_purchased
  end

  def eligible_for_financials?
    ((end_date + 20) > Date.today) || has_online_sale && (online_sale_end_date.not_nil? && (online_sale_end_date.to_date + 20) < Date.today)
  end

  def number_of_possible_sale_items
    items_coming.nil? ? possible_sale_items.count : items_coming
  end

  def possible_sale_items
    sale_items = []
    for consignor in consignor_profiles
      sale_items += consignor.franchise_profile.profile.items_coming_to_sale
    end
    return sale_items
  end

  def number_of_featured_items
    featured_items.nil? ? featured_items.count : featured_items
  end

  def featured_items_old(category = nil, sub_category = nil, size = nil)
    sale_items = []
    additional_conditions = []
    additional_conditions << "category = ?" unless category.empty_or_nil?
    additional_conditions << "sub_category = ?" unless sub_category.empty_or_nil?
    additional_conditions << "size = ?" unless size.empty_or_nil?
    rvalue = [additional_conditions.join(" AND ")]
    rvalue << category unless category.empty_or_nil?
    rvalue << sub_category unless sub_category.empty_or_nil?
    rvalue << size unless size.empty_or_nil?
    for consignor in consignor_profiles
      if additional_conditions.empty?
        sale_items += consignor.franchise_profile.profile.featured_items
      else
        sale_items += consignor.franchise_profile.profile.featured_items.find(:all, :conditions => rvalue)
      end
    end
    sale_items.sort! { |a, b| b.id <=> a.id }
    rvalue = []
    return sale_items
  end

  def featured_items(category = nil, sub_category = nil, size = nil)
    sale_items = []
    additional_conditions = []
    additional_conditions << "category = ?" unless category.empty_or_nil?
    additional_conditions << "sub_category = ?" unless sub_category.empty_or_nil?
    additional_conditions << "size = ?" unless size.empty_or_nil?
    rvalue = [additional_conditions.join(" AND ")]
    rvalue << category unless category.empty_or_nil?
    rvalue << sub_category unless sub_category.empty_or_nil?
    rvalue << size unless size.empty_or_nil?
    if additional_conditions.empty?
      sale_items = franchise.items_for_sale_online
    else
      sale_items = franchise.items_for_sale_online.find(:all, :conditions => rvalue)
    end
    rvalue = []
    profile_ids = []
    for consignor in consignor_profiles
      profile_ids << consignor.franchise_profile.profile_id
    end
    for item in sale_items
      rvalue << item if !item.status && item.donate_date.empty_or_nil? && profile_ids.include?(item.profile_id)
    end
    return rvalue
  end

  def load_featured_items
    for item in possible_sale_items
      if item.featured_item
        franchise_assignment = item.item_franchise_relationships.find(:first, :conditions => ["franchise_id = ?", franchise_id])
        if franchise_assignment.nil?
          franchise_assignment = ItemFranchiseRelationship.new
          franchise_assignment.consignor_inventory_id = item.id
          franchise_assignment.franchise_id = franchise_id
          franchise_assignment.save
        end
      end
    end
  end

  def autocomplete_list
    rvalue = []
    for item in featured_items
      rvalue << "'" + item.item_description.gsub(/[^0-9a-z ]/i, '') + "'"
    end
    rvalue = rvalue.uniq
    #return rvalue.join(",")
  end

  def tagged_items
    tagged_items = 0
    for consignor in consignor_profiles
      tagged_items += consignor.franchise_profile.profile.items_coming_to_sale.count(:id, :conditions => ["printed = ?", true])
    end
    return tagged_items
  end

  def possible_sale_items_search(profile, conditions)
    sale_items = []
    if profile.nil?
      for consignor in consignor_profiles        
        sale_items += conditions.nil? ? consignor.franchise_profile.profile.items_coming_to_sale : consignor.franchise_profile.profile.items_coming_to_sale.find(:all, :conditions => conditions)
      end
    else
      sale_items += conditions.nil? ? profile.items_coming_to_sale : profile.items_coming_to_sale.find(:all, :conditions => conditions)
    end
    return sale_items
  end

  def featured_item_search_old(search_term, category = nil, sub_category = nil, size = nil)
    sale_items = []
    for consignor in consignor_profiles
      sale_items += consignor.franchise_profile.profile.featured_item_search(search_term, category, sub_category, size)
    end
    sale_items.sort!{|a,b| (b[1] <=> a[1]) == 0 ? (b[0].id <=> a[0].id) : (b[1] <=> a[1]) }
    rvalue = []
    for item in sale_items
      rvalue << item[0]
    end
    return rvalue
  end

  def featured_item_search(search_term, category = nil, sub_category = nil, size = nil)
    like_conditions = [
      "item_description = ?",
      "item_description LIKE ?",
      "item_description LIKE ?",
      "item_description LIKE ?",
      "additional_information LIKE (?)",
      "consignor_inventories.id = ?"
    ]
    rvalue = nil
    additional_conditions = []
    additional_conditions << "category = ?" unless category.empty_or_nil?
    additional_conditions << "sub_category = ?" unless sub_category.empty_or_nil?
    additional_conditions << "size = ?" unless size.empty_or_nil?
    conditions_array = []
    unless search_term.nil? || search_term.empty?
      tags = search_term.split(" ") 
      tags.each(&:strip!)
      tags.delete("size")
      tags.delete("Size")
      base_value = "(#{like_conditions.join(" OR ")})"
      tags.length.times do
        conditions_array << base_value
      end
    else
      tags = []
    end
    if additional_conditions.empty?
      rvalue = [conditions_array.join(" OR " )]
    else
      rvalue = [additional_conditions.join(" AND ") + " AND (" + conditions_array.join(" OR " ) + ")"]
    end
    rvalue << category unless category.empty_or_nil?
    rvalue << sub_category unless sub_category.empty_or_nil?
    rvalue << size unless size.empty_or_nil?
    for tag in tags
      rvalue << "#{tag}"
      rvalue << "#{tag} %"
      rvalue << "% #{tag}"
      rvalue << "% #{tag} %"
      rvalue << "%#{tag}%"
      rvalue << tag
    end
    items = franchise.items_for_sale_online.find(:all, :conditions => rvalue)
    item_array = []
    unless search_term.empty_or_nil?
      for item in items
        tag_count = 0
        tag_count += 100 if item.item_description.not_nil? && item.item_description.downcase.include?(" #{search_term.downcase} ")
        tag_count += 100 if item.item_description.not_nil? && item.item_description.downcase.start_with?(search_term.downcase)
        tag_count += 100 if item.item_description.not_nil? && item.item_description.downcase.end_with?(search_term.downcase)
        tag_count += 50 if item.additional_information.not_nil? && item.additional_information.downcase.include?(" #{search_term.downcase} ")
        tag_count += 50 if item.additional_information.not_nil? && item.additional_information.downcase.start_with?(search_term.downcase)
        tag_count += 50 if item.additional_information.not_nil? && item.additional_information.downcase.end_with?(search_term.downcase)
        for tag in tags
          tag_count += 10 if item.item_description.not_nil? && item.item_description.downcase.split.include?(tag.downcase)
          tag_count += 5 if item.additional_information.not_nil? && item.additional_information.downcase.split.include?(tag.downcase)
        end
        item_array << [item, tag_count]
      end
    else
      for item in items
        item_array << [item, 0]
      end
    end
    item_array.sort!{|a,b| (b[1] <=> a[1]) == 0 ? (b[0].id <=> a[0].id) : (b[1] <=> a[1]) }
    rvalue = []
    profile_ids = []
    for consignor in consignor_profiles
      profile_ids << consignor.franchise_profile.profile_id
    end
    for item in item_array
      rvalue << item[0] if profile_ids.include?(item[0].profile_id)
    end
    return rvalue
  end

  def consignor_profiles_for_sort_column(sort_column)
    consignor_profiles.find(:all, :conditions => ["profiles.sort_column = ? AND quantity_sold > ?", sort_column, 0], :order => "profiles.id")
  end

  def formatted_address
    return %{
      <div id="formatted_address_#{self.id}" class="formatted_address">
        #{self.facility_name + "<br>" unless self.facility_name.blank?}
        #{self.sale_address}<br>
        #{self.franchise.sale_city}, #{self.franchise.province.name} #{self.sale_zip_code}
      </div>
    }
  end

  def formatted_address_2017
    return %{
        #{"<h3>" + self.facility_name + "</h3>" unless self.facility_name.blank?}
        <p>#{self.sale_address}<br>
        #{self.franchise.sale_city}, #{self.franchise.province.name} #{self.sale_zip_code}</p>
    }
  end

  def pdf_address
    return %{
        #{self.sale_address2[0..37] + "<br>" unless self.sale_address2.blank?}
        #{self.sale_address[0..37]}<br>
        #{self.franchise.sale_city}, #{self.franchise.province.name} #{self.sale_zip_code}
    }
  end

  def geocode_address
    return [sale_address, franchise.sale_city, franchise.province.name, sale_zip_code].compact.join(', ')
  end

  def bing_url
    "http://www.bing.com/maps/?v=2&where1=#{sale_address}, #{franchise.sale_city}, #{franchise.province.name} #{self.sale_zip_code}"
  end

  def flyer_footer_image
    sale_percentage.to_i == 70 ? 'kcc_spring_flyer_bottom_70.jpg' : 'kcc_spring_flyer_bottom.jpg'
  end

  def calculate_financials
    self.verify_consignor_sign_up_duplicates
    if reward_profile_ids.not_blank?
      for reward_profile_id in reward_profile_ids
        reward_result = rewards_profile_sale_results.find(:first, :conditions => ["rewards_profile_id = ?", reward_profile_id])
        reward_result ||= RewardsProfileSaleResult.new
        if reward_result.new_record?
          reward_result.sale = self
          reward_result.rewards_profile = RewardsProfile.find(reward_profile_id)
        end
        reward_result.amount_purchased = reward_result.rewards_profile.amount_purchased(self.id)
        reward_result.save
      end
      obsolete_results = rewards_profile_sale_results.find(:all, :conditions => ["rewards_profile_id NOT IN (#{reward_profile_ids.join(", ")})"])
      for reward_result in obsolete_results
        reward_result.destroy
      end
    else
      for reward_result in rewards_profile_sale_results
        reward_result.destroy
      end
    end
    for consignor_sign_up in consignor_profiles
      consignor_sign_up.quantity_sold = consignor_sign_up.calculate_quantity_sold
      consignor_sign_up.total_sold = consignor_sign_up.calculate_total_sold
      consignor_sign_up.advertisement_fee_paid = consignor_sign_up.calculate_advertisement_fee
      consignor_sign_up.percentage_fee_paid = consignor_sign_up.calculate_percentage_fee
      consignor_sign_up.save
    end
    self.tax_received = self.calculate_tax_collected
    self.transaction_count = self.calculate_number_of_transactions
    self.total_items_sold = self.calculate_number_of_items_sold
    self.total_amount_sold = self.calculate_total_sold
    self.save
  end

  def verify_consignor_sign_up_duplicates
    count1 = consignor_profiles.count
    count2 = SaleConsignorSignUp.find(:all, :select => "DISTINCT sale_consignor_sign_ups.franchise_profile_id", :joins => :sale_consignor_time, :conditions => ["sale_consignor_times.sale_id = ?", self.id]).count
    if count1 != count2
      for consignor in consignor_profiles
        count3 = SaleConsignorSignUp.count(:id, :joins => :sale_consignor_time, :conditions => ["sale_consignor_sign_ups.franchise_profile_id = ? AND sale_consignor_times.sale_id = ?", consignor.franchise_profile_id, self.id])
        if count3 > 1
          consignor_profile = SaleConsignorSignUp.find(:last, :joins => :sale_consignor_time, :conditions => ["sale_consignor_sign_ups.franchise_profile_id = ? AND sale_consignor_times.sale_id = ?", consignor.franchise_profile_id, self.id])
          consignor_profile.destroy
        end
      end
    end
  end
  
  class << self
    def latest_sale_for_franchise(franchise_id)
      return find(:first, :conditions => ["franchise_id = ?", franchise_id], :order => "start_date DESC")
    end
    
    def current_active_sale(franchise_id)
      return find(:first, :conditions => ["franchise_id = ? AND active = ?", franchise_id, 1])
    end
    
    def current_active_sale_id(franchise_id)
      sale = find(:first, :conditions => ["franchise_id = ? AND active = ?", franchise_id, 1])
      return sale.nil? ? nil : sale.id
    end

    def consignor_sort_options
      [["Consignor #", "id"], ["Name", ""], ["Email Address", "email"]]
    end
    
    def calculate_sale_financials_after_refund(consignor_inventory)
      sale = consignor_inventory.sale
      profile_id = consignor_inventory.profile_id
      rewards_profile_id = consignor_inventory.rewards_profile_id
      consignor_inventory.sale_id = nil
      consignor_inventory.discounted_at_sale = nil
      consignor_inventory.sale_price = nil
      consignor_inventory.tax_collected = nil
      consignor_inventory.total_price = nil
      consignor_inventory.sale_date = nil
      consignor_inventory.transaction_number = nil
      consignor_inventory.import_error_comment = nil
      consignor_inventory.rewards_profile_id = nil
      consignor_inventory.status = false
      consignor_inventory.sold_online = false
      consignor_inventory.save
      consignor_inventory.order.destroy unless consignor_inventory.order.nil?
      if rewards_profile_id.not_nil?      
        reward_result = sale.rewards_profile_sale_results.find(:first, :conditions => ["rewards_profile_id = ?", rewards_profile_id])
        reward_result.amount_purchased = reward_result.rewards_profile.amount_purchased(sale.id)
        reward_result.save
      end
      consignor_sign_up = sale.consignor_profiles.find(:first, :conditions => ["profiles.id = ?", profile_id])
      consignor_sign_up.quantity_sold = consignor_sign_up.calculate_quantity_sold
      consignor_sign_up.total_sold = consignor_sign_up.calculate_total_sold
      consignor_sign_up.advertisement_fee_paid = consignor_sign_up.calculate_advertisement_fee
      consignor_sign_up.percentage_fee_paid = consignor_sign_up.calculate_percentage_fee
      consignor_sign_up.save
      sale.tax_received = sale.calculate_tax_collected
      sale.transaction_count = sale.calculate_number_of_transactions
      sale.total_items_sold = sale.calculate_number_of_items_sold
      sale.total_amount_sold = sale.calculate_total_sold
      sale.save      
    end

    def sale_percentage_options
      [[65, "65%"], [70, "70%"], [75, "75%"], [80, "80%"]]
    end
  end

  def next_available_business_partner_sort_index
    if business_partners.empty?
      return 1
    else
      return business_partners.maximum(:sort_index) + 1
    end    
  end

  def number_of_volunteer_job_shifts
    active_volunteer_jobs.count
  end

  def filled_volunteer_job_shifts
    rvalue = 0
    active_volunteer_jobs.each do |sale_volunteer_time| 
      rvalue += 1 if sale_volunteer_time.is_full?
    end
    return rvalue
  end
  
  def open_volunteer_job_shifts
    number_of_volunteer_job_shifts - filled_volunteer_job_shifts
  end
  
  def has_open_volunteer_jobs?
    open_volunteer_job_shifts > 0
  end
  
  def number_of_volunteer_jobs
    sale_volunteer_times.sum(:number_of_spots)
  end
  
  def volunteer_job_spots_left
    rvalue = 0
    sale_volunteer_times.each do |sale_volunteer_time| 
      rvalue += sale_volunteer_time.spots_left
    end
    return rvalue    
  end
  
  def volunteer_jobs_filled
    number_of_volunteer_jobs - volunteer_job_spots_left
  end
  
  def volunteer_jobs_status
    "#{volunteer_jobs_filled} out of #{number_of_volunteer_jobs}"
  end

  def items_coming_export_path
    "#{RAILS_ROOT}/public/assets/1/#{items_coming_export_file_name}"
  end

  def items_coming_export_file_name
    return "sale_#{id}_items_coming.csv"
  end

  def items_coming_export_notification
    return "Your export file can be downloaded from http://www.kidscloset.biz/assets/1/#{items_coming_export_file_name}"
  end

  def consignor_history_export_file_name
    return "sale_#{id}_consignors_history_export.csv"
  end

  def consignor_history_export_path
    "#{RAILS_ROOT}/public/assets/1/#{consignor_history_export_file_name}"
  end

  def consignor_history_export_notification
    return "Your export file can be downloaded from http://www.kidscloset.biz/assets/1/#{consignor_history_export_file_name}"
  end

  def promo_codes_for_sale
    SaleConsignorSignUp.find(:all, :select => "DISTINCT sale_consignor_sign_ups.promo_code", :joins => " INNER JOIN sale_consignor_times t ON t.id = sale_consignor_sign_ups.sale_consignor_time_id", :conditions => ["t.sale_id = ? AND sale_consignor_sign_ups.promo_code IS NOT NULL", id], :order => "sale_consignor_sign_ups.promo_code")
  end

  def promo_codes_count(promo_code)
    SaleConsignorSignUp.count(:id, :joins => " INNER JOIN sale_consignor_times t ON t.id = sale_consignor_sign_ups.sale_consignor_time_id", :conditions => ["t.sale_id = ? AND sale_consignor_sign_ups.promo_code = ?", id, promo_code])
  end

  private 
    def set_previous_sale_percentage
      self.previous_sale_percentage = sale_percentage_was if sale_percentage_changed?
    end
  
    def inactivate_old_sale_if_active
      if self.active
        last_active_sale = Sale.current_active_sale(self.franchise_id)
        unless last_active_sale.nil? || last_active_sale.id == self.id
          last_active_sale.active = false
          last_active_sale.save
        end
      end
    end

    def add_internal_consignor_time
      SaleConsignorTime.create(
          :sale_id => self.id,
          :date => Date.today - 365,
          :start_time => Time.now - 360,
          :end_time => Time.now,
          :number_of_spots => 9999,
          :internal => true)
    end

    def identify_and_assign_sale_season
      sale_season = SaleSeason.find(:first, :conditions => ["start_date < ? AND end_date > ?", self.start_date, self.end_date])
      self.sale_season_id = sale_season.id if self.sale_season.nil? && sale_season.not_nil?
    end

    def update_consignors_with_new_percentage
      for sign_up in consignor_profiles
        if sign_up.sale_percentage == previous_sale_percentage.to_i
          sign_up.sale_percentage = sale_percentage
          sign_up.save
        end
      end
    end

    def create_geocode
      self.latitude, self.longitude = ZipCode.return_coordinates(sale_zip_code)
    end
end
