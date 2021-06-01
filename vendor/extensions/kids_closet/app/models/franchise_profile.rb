class FranchiseProfile < ActiveRecord::Base
  belongs_to :franchise
  belongs_to :profile
  has_many :sale_consignor_sign_ups, :dependent => :destroy
  has_many :sale_volunteer_sign_ups, :dependent => :destroy  

  acts_as_site_member

  validates_presence_of :franchise_id, :profile_id
  validates_uniqueness_of :profile_id, :scope => :franchise_id, :message => "You are already registered for this franchise."
  validates_numericality_of :franchise_id, :greater_than => 0

  after_update :add_or_remove_items_from_franchise_sale_list
    
  def validate
    errors.add(:franchise_id, " Must be a helper or consignor to be active") if active && (!consignor && !volunteer)
    errors.add(:franchise_id, " Must be either a consignor, volunteer or member list member") if !mailing_list && !active && new_record?
    errors.add(:profile_id, " You have hit a rare error that we are trying to figure out how to duplicate.  Please email the exact steps you have taken to create this profile.") if profile_id == -1 || profile_id == 0
  end
  
  def transfer?
    return FranchiseProfile.find(:first, :conditions => ["created_at < ? AND profile_id = ?", self.created_at, self.profile_id]).not_nil?
  end
  
  def self.sign_up_to_consign_active_sale(franchise_profile)
    consignor_sign_up = SaleConsignorSignUp.new
    consignor_sign_up.franchise_profile_id = franchise_profile.id
    active_sale_id = Sale.current_active_sale_id(franchise_profile.franchise_id)
    unless active_sale_id.nil?
      consignor_sign_up.sale_consignor_time_id = SaleConsignorTime.internal_time_for_sale(active_sale_id)
      consignor_sign_up.promo_code = franchise_profile.profile.promo_code
      consignor_sign_up.save
    end
    profile = franchise_profile.profile
    profile.promo_code = nil
    profile.save_with_validation(false)
  end

  def consignor_sale_ids
    ids = []
    for sign_up in sale_consignor_sign_ups
      ids << sign_up.sale_consignor_time.sale_id
    end
    return ids
  end

  def is_current_consignor?
    return false if franchise.active_sale_id.nil?
    return true if consignor_sale_ids.include?(franchise.active_sale_id)
  end

  def sales_consigned
    Sale.find(:all, :conditions => ["id IN (?) AND end_date <= ?", consignor_sale_ids, Date.today])
  end

  def number_of_sales_consigned
    sale_consignor_sign_ups.count(:id, :conditions => ["quantity_sold > ?", 0])
  end

  def lifetime_quantity_sold
    sale_consignor_sign_ups.sum(:quantity_sold)
  end

  def lifetime_total_sold
    sale_consignor_sign_ups.sum(:total_sold)
  end

  def last_consign_date
    dates = []
    for sale in sales_consigned
      dates << sale.end_date
    end
    dates.empty? ? "N/A" : dates.max.strftime("%B %d, %Y") 
  end

  def previous_sale_sign_up(sale_id = nil)
    return nil if franchise.previous_sale.nil?
    sale_consignor_sign_ups.find(:first, 
      :joins => "INNER JOIN sale_consignor_times t ON sale_consignor_sign_ups.sale_consignor_time_id = t.id", 
      :conditions => ["t.sale_id = ?", sale_id.nil? ? franchise.previous_sale.id : sale_id])
  end

  def last_sale_proceeds(sale_id = nil)
    previous_sale_sign_up.nil? ? 0 : previous_sale_sign_up.total_sold
  end

  def last_sale_quantity_sold(sale_id = nil)
    previous_sale_sign_up.nil? ? 0 : previous_sale_sign_up.quantity_sold
  end

  def unsold_items
    profile.unsold_items.count
  end

  def unsold_items_value
    profile.unsold_items.sum(:price)
  end

  def items_coming
    profile.items_coming
  end

  def inactive_items
    unsold_items - items_coming
  end

  def volunteer_sale_ids
    ids = []
    for sign_up in sale_volunteer_sign_ups
      ids << sign_up.sale_volunteer_time.sale_id
    end
    ids = ids.uniq
    return ids
  end

  def is_current_volunteer?
    return false if franchise.active_sale_id.nil?
    return true if volunteer_sale_ids.include?(franchise.active_sale_id)
  end

  def volunteered_in_sale?(sale_id)
    return volunteer_sale_ids.include?(sale_id)
  end

  def sales_volunteered
    Sale.find(:all, :conditions => ["id IN (?)", volunteer_sale_ids])
  end

  def number_of_sales_volunteered
    sales_volunteered.count
  end

  def last_volunteer_date
    dates = []
    for sale in sales_volunteered
      dates << sale.end_date
    end
    dates.empty? ? "N/A" : dates.max.strftime("%B %d, %Y") 
  end

  def last_sale_volunteer_slots(sale_id = nil)
    sale_volunteer_sign_ups.count(:id, 
      :joins => "INNER JOIN sale_volunteer_times t ON sale_volunteer_sign_ups.sale_volunteer_time_id = t.id", 
      :conditions => ["t.sale_id = ?", sale_id.nil? ? franchise.active_sale_id : sale_id])
  end

  def lifetime_volunteer_slots
    sale_volunteer_sign_ups.count(:id, 
      :joins => "INNER JOIN sale_volunteer_times t ON sale_volunteer_sign_ups.sale_volunteer_time_id = t.id", 
      :conditions => ["t.sale_id IN (?)", sales_volunteered.map(&:id)])
  end

  private 

  def add_or_remove_items_from_franchise_sale_list
    if Franchise.franchises_with_online_sales.include?(franchise_id)
      for item in profile.featured_items
        franchise_assignment = item.item_franchise_relationships.find(:first, :conditions => ["franchise_id = ?", franchise_id])
        if consignor
          franchise_assignment = ItemFranchiseRelationship.new
          franchise_assignment.consignor_inventory_id = item.id
          franchise_assignment.franchise_id = franchise_id
          franchise_assignment.save        
        else
          franchise_assignment.destroy unless franchise_assignment.nil?
        end
      end
    end
  end
end
