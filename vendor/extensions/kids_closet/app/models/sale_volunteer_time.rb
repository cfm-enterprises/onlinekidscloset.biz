class SaleVolunteerTime < ActiveRecord::Base
  belongs_to :sale
  has_many :sale_volunteer_sign_ups, :dependent => :destroy
  has_many :volunteer_profiles, :class_name => "FranchiseProfile", :include => :profile, :order => "profiles.last_name, profiles.first_name", :through => :sale_volunteer_sign_ups, :source => :franchise_profile

  acts_as_site_member

  validates_presence_of :sale_id, :number_of_spots, :date, :start_time, :end_time, :job_title
  validates_numericality_of :number_of_spots, :greater_than => 0, :only_integer => true
  
  def validate
    errors.add(:end_time, "should be greater than the Start Time" ) if !none_traditional_job && start_time.nil? || end_time.nil? || start_time > end_time
    unless id.nil?
      number_of_existing_sign_ups = volunteer_profiles.count(:id)
      errors.add(:number_of_spots, "can not be lower than number of helpers already signed up (#{number_of_existing_sign_ups})") if number_of_existing_sign_ups > number_of_spots
    end
  end
  
  def spots_left
    return number_of_spots - volunteer_profiles.count
  end
  
  def is_full?
    spots_left == 0
  end
  
  def is_open?
    !is_full?
  end

  class << self
    def latest_volunteer_time_for_sale(sale_id)
      return find(:first, :conditions => ["sale_id = ? AND end_time > start_time", sale_id], :order => "id DESC")
    end
  end
end
