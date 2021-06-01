class SaleConsignorSignUp < ActiveRecord::Base
  belongs_to :franchise_profile
  belongs_to :sale_consignor_time
  
  acts_as_site_member

  before_validation :add_default_costs_if_blank_and_remove_internal_record_if_duplicate
  
  validates_presence_of :franchise_profile_id, :sale_consignor_time_id
  validates_numericality_of :sale_percentage, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100
  validates_numericality_of :sale_advert_cost, :greater_than_or_equal_to => 0
  validates_numericality_of :fee_adjustment
  validates_uniqueness_of :franchise_profile_id, :scope => :sale_consignor_time_id, :message => " is already signed up for this drop off time"
    
  after_create :add_items_from_franchise_sale_list
  before_destroy :remove_items_from_franchise_sale_list
  
  def validate
    #make sure consignor is not already signed up for another drop off time
    duplicate_sign_up = SaleConsignorSignUp.non_internal_consignor_sign_up_for_sale(sale_consignor_time.sale_id, franchise_profile_id)
    errors.add(:franchise_profile_id, "Already Signed Up for this Sale") if duplicate_sign_up.not_nil? && new_record?
    
    #make sure we are not over the available number of time slots
    number_of_consignors = sale_consignor_time.sale_consignor_sign_ups.find(:all, :conditions => ["id != ?",  new_record? ? 0 : id]).length
    errors.add(:sale_consignor_time_id, ": No More Drop Off Slots available for this time") if number_of_consignors >= sale_consignor_time.number_of_spots 
  end

  def sale_name
    "#{self.sale_consignor_time.sale.franchise.franchise_name} (#{self.sale_consignor_time.sale.sale_dates})"
  end
  
  def items_sold
    self.franchise_profile.profile.sold_items.find(:all, :conditions => ["sale_id = ?", self.sale_consignor_time.sale_id])
  end

  def calculate_quantity_sold
    self.items_sold.empty? ? 0 : self.items_sold.count
  end  
  
  def calculate_total_sold
    self.franchise_profile.profile.sold_items.sum(:sale_price, :conditions => ["sale_id = ?", self.sale_consignor_time.sale_id])
  end

  def consignor_proceeds
    self.total_sold - self.percentage_fee_paid + self.fee_adjustment
  end

  def calculate_percentage_fee
    value = self.calculate_total_sold * (1 - (self.sale_percentage / 100))
    value = (value * 10**2).round.to_f / 10 ** 2
  end

  def advertisement_fees_paid    
    franchise_profiles = self.franchise_profile.profile.franchise_profiles.find(:all, :conditions => ["franchise_id != ?", self.sale_consignor_time.sale.franchise_id])
    advertisement_fee_paid = 0
    for franchise_profile in franchise_profiles
      sale = franchise_profile.franchise.sales.find(:first, :conditions => ["sale_season_id = ?", self.sale_consignor_time.sale.sale_season_id])
      unless sale.nil?
        consignor_sign_up = SaleConsignorSignUp.consignor_sign_up_for_sale(sale.id, franchise_profile.id)
        unless consignor_sign_up.nil? 
          advertisement_fee_paid += consignor_sign_up.advertisement_fee_paid
        end
      end
    end
    return advertisement_fee_paid          
  end

  def estimated_advertisement_fee
#    [0, self.sale_advert_cost - self.advertisement_fees_paid].max
    self.sale_advert_cost
  end

  def calculate_advertisement_fee
    [self.calculate_total_sold - self.calculate_percentage_fee, self.estimated_advertisement_fee].min
  end

  def check_amount
    self.consignor_proceeds - self.advertisement_fee_paid
  end
  
  class << self
    def consignor_sign_up_for_sale(sale_id, franchise_profile_id)
      return SaleConsignorSignUp.find(:first, :joins => :sale_consignor_time, :conditions => ["sale_consignor_sign_ups.franchise_profile_id = ? AND sale_consignor_times.sale_id = ?", franchise_profile_id, sale_id])
    end
    
    def non_internal_consignor_sign_up_for_sale(sale_id, franchise_profile_id)
      return SaleConsignorSignUp.find(:first, :joins => :sale_consignor_time, :conditions => ["sale_consignor_sign_ups.franchise_profile_id = ? AND sale_consignor_times.sale_id = ? AND sale_consignor_times.internal = ?", franchise_profile_id, sale_id, false])
    end
    
    def internal_consignor_sign_up_for_sale(sale_id, franchise_profile_id)
      return SaleConsignorSignUp.find(:first, :joins => :sale_consignor_time, :conditions => ["sale_consignor_sign_ups.franchise_profile_id = ? AND sale_consignor_times.sale_id = ? AND sale_consignor_times.internal = ?", franchise_profile_id, sale_id, true])
    end
  
    def consignors_for_sale(sale_id)
      return SaleConsignorSignUp.find(:all, :select => "sale_consignor_sign_ups.*", :joins => :sale_consignor_time, :conditions => ["sale_id = ?", sale_id])
    end
    
    def non_internal_consignors_for_sale(sale_id)
      return SaleConsignorSignUp.find(:all, :select => "sale_consignor_sign_ups.*", :joins => :sale_consignor_time, :conditions => ["sale_id = ? AND internal = ?", sale_id, false])
    end

    def load_available_consignors(sale_consignor_time)
      if sale_consignor_time.internal
        conflicting_records = SaleConsignorSignUp.consignors_for_sale(sale_consignor_time.sale_id)
      else
        conflicting_records = SaleConsignorSignUp.non_internal_consignors_for_sale(sale_consignor_time.sale_id)
      end      
      return FranchiseProfile.find(:all, :joins => :profile, 
                    :conditions => ['franchise_profiles.id not in (?) AND franchise_id = ? AND consignor = ? AND active = ?', 
                      conflicting_records.empty? ? 0 : conflicting_records.map(&:franchise_profile_id), 
                      sale_consignor_time.sale.franchise_id, true, true], :order => "last_name, first_name")
    end

    def current_season_sign_ups_for_profile(profile_id)
      return SaleConsignorSignUp.find(:all, :joins => [:franchise_profile, [:sale_consignor_time => :sale]], :conditions => ["franchise_profiles.profile_id = ?", profile_id], :order => 'sales.start_date DESC')
      return SaleConsignorSignUp.find(:all, :joins => [:franchise_profile, [:sale_consignor_time => :sale]], :conditions => ["franchise_profiles.profile_id = ? AND sales.sale_season_id = ?", profile_id, SaleSeason.current_sale_season_id])
    end

    def sale_percentage_options(current_percentage)
      rvalue = []
      rvalue << ["#{current_percentage}%", current_percentage] unless [65, 70, 75, 80].include?(current_percentage.to_i)
      rvalue << ["65%", 65]
      rvalue << ["70%", 70]
      rvalue << ["75%", 75]
      rvalue << ["80%", 80]
      rvalue
    end
  end
    
  protected

  def add_items_from_franchise_sale_list
    if Franchise.franchises_with_online_sales.include?(sale_consignor_time.sale.franchise_id)
      for item in franchise_profile.profile.featured_items
        franchise_assignment = item.item_franchise_relationships.find(:first, :conditions => ["franchise_id = ?", sale_consignor_time.sale.franchise_id])
        franchise_assignment = ItemFranchiseRelationship.new
        franchise_assignment.consignor_inventory_id = item.id
        franchise_assignment.franchise_id = sale_consignor_time.sale.franchise_id
        franchise_assignment.save        
      end
    end
  end
  
  def remove_items_from_franchise_sale_list
    if Franchise.franchises_with_online_sales.include?(sale_consignor_time.sale.franchise_id)
      for item in franchise_profile.profile.featured_items
        franchise_assignment = item.item_franchise_relationships.find(:first, :conditions => ["franchise_id = ?", sale_consignor_time.sale.franchise_id])
        franchise_assignment.destroy unless franchise_assignment.nil?
      end
    end
  end

  def add_default_costs_if_blank_and_remove_internal_record_if_duplicate
    unless self.sale_consignor_time.internal
      internal_record = SaleConsignorSignUp.internal_consignor_sign_up_for_sale(self.sale_consignor_time.sale_id, self.franchise_profile_id)
      unless internal_record.nil? || internal_record.id == self.id
        self.sale_advert_cost = internal_record.sale_advert_cost
        self.sale_percentage = internal_record.sale_percentage
        self.comments = internal_record.comments
        internal_record.destroy
      end
    end
    if !self.sale_consignor_time.nil?
      self.sale_advert_cost = self.sale_consignor_time.sale.sale_advert_cost if self.sale_percentage == 0 || self.sale_percentage.blank?
      self.sale_percentage = self.sale_consignor_time.sale.sale_percentage if self.sale_percentage == 0 || self.sale_percentage.blank?
    end
  end  
end
