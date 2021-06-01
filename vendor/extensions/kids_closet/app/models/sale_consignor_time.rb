class SaleConsignorTime < ActiveRecord::Base
  belongs_to :sale
  has_many :sale_consignor_sign_ups, :dependent => :destroy
  has_many :consignor_profiles, :class_name => "FranchiseProfile", :include => :profile, :order => "profiles.last_name, profiles.first_name", :through => :sale_consignor_sign_ups, :source => :franchise_profile

  acts_as_site_member

  validates_presence_of :sale_id, :number_of_spots, :date, :start_time, :end_time
  validates_uniqueness_of :start_time, :scope => [:sale_id, :date]
  validates_numericality_of :number_of_spots, :greater_than => 0, :only_integer => true
  
  def validate
    errors.add(:end_time, "should be greater than the Start Time" ) if start_time.nil? || end_time.nil? || start_time > end_time
    unless id.nil?
      number_of_existing_sign_ups = consignor_profiles.count(:id)
      errors.add(:number_of_spots, "can not be lower than number of consignors already signed up (#{number_of_existing_sign_ups})") if number_of_existing_sign_ups > number_of_spots
    end
  end

  def spots_left
    return number_of_spots - consignor_profiles.count
  end

  def items_coming
    count = 0
    for consignor in consignor_profiles
      count += consignor.profile.items_coming
    end
    return count
  end

  class << self
    def latest_consignor_time_for_sale(sale_id)
      return find(:first, :conditions => ["sale_id = ? AND internal = ? AND end_time > start_time", sale_id, false], :order => "id DESC")
    end
    
    def internal_time_for_sale(sale_id)
      return find(:first, :conditions => ["sale_id = ? AND internal = ?", sale_id, true]).id
    end
  end
end
