class SaleVolunteerSignUp < ActiveRecord::Base
  belongs_to :franchise_profile
  belongs_to :sale_volunteer_time
  
  acts_as_site_member

  validates_presence_of :franchise_profile_id, :sale_volunteer_time_id
  validates_uniqueness_of :franchise_profile_id, :scope => :sale_volunteer_time_id, :message => " is already helping for this job"
  
  def validate
    #make sure we are not over the available number of time slots
    number_of_volunteers = sale_volunteer_time.sale_volunteer_sign_ups.find(:all, :conditions => ["id != ?",  new_record? ? 0 : id]).length
    errors.add(:sale_volunteer_time_id, ": No More Helper Slots available for this time") if number_of_volunteers >= sale_volunteer_time.number_of_spots 
    
    #only allow 6 jobs per person
    if sale_volunteer_time.not_nil? && new_record?
      number_of_jobs_for_volunteer_in_sale = SaleVolunteerSignUp.number_of_jobs_for_volunteer_in_sale(franchise_profile_id, sale_volunteer_time.sale_id)
      errors.add(:franchise_profile_id, " is already signed up for the maximum number of jobs") if number_of_jobs_for_volunteer_in_sale >= 6
    end

    #must be active consignor with more than one active item
    if franchise_profile.consignor
      errors.add(:franchise_profile_id, " must have at last one active item for sale") if franchise_profile.profile.items_coming < 0
    else
      errors.add(:franchise_profile_id, " must be a consignor on this sale")
    end
  end
  
  class << self
    def volunteer_sign_ups_for_sale(sale_id, franchise_profile_id)
      return SaleVolunteerSignUp.find(:all, :joins => :sale_volunteer_time, :conditions => ["franchise_profile_id = ? AND sale_id = ?", franchise_profile_id, sale_id])
    end
    
    def volunteers_for_sale(sale_id)
      return SaleVolunteerSignUp.find(:all, :select => "sale_volunteer_sign_ups.*", :joins => :sale_volunteer_time, :conditions => ["sale_id = ?", sale_id])
    end

    def load_available_volunteers(sale_volunteer_time)
      sale_volunteers = SaleVolunteerSignUp.volunteers_for_sale(sale_volunteer_time.sale_id)
      conflicting_records = []
      sale_volunteers.each do |volunteer|
        conflicting_records << volunteer if SaleVolunteerSignUp.number_of_jobs_for_volunteer_in_sale(volunteer.franchise_profile_id, sale_volunteer_time.sale_id) >= 6
        conflicting_records << volunteer if volunteer.sale_volunteer_time_id == sale_volunteer_time.id
      end
      return FranchiseProfile.find(:all, :joins => :profile, 
                    :conditions => ['franchise_profiles.id not in (?) AND franchise_id = ? AND volunteer = ? AND active = ?', 
                      conflicting_records.empty? ? 0 : conflicting_records.map(&:franchise_profile_id), 
                      sale_volunteer_time.sale.franchise_id, true, true], :order => "last_name, first_name")
    end
    
    def number_of_jobs_for_volunteer_in_sale(franchise_profile_id, sale_id)
      return SaleVolunteerSignUp.count(:franchise_profile_id, :joins => :sale_volunteer_time, :conditions => ["sale_volunteer_times.sale_id = ? AND sale_volunteer_sign_ups.franchise_profile_id = ?", sale_id, franchise_profile_id])      
    end
  end
end
