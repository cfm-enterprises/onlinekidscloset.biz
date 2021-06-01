class FranchiseOwnerProfile < ActiveRecord::Base
  belongs_to :franchise
  belongs_to :profile
  
  acts_as_site_member

  validates_presence_of :franchise_id, :profile_id
  validates_uniqueness_of :profile_id, :scope => :franchise_id, :message => "The user is already a franchise owner for the selected franchise"

  class << self
	  def score_card_export_path(profile_id = nil)
	    "#{RAILS_ROOT}/public/assets/1/#{self.score_card_export_file_name(profile_id)}"
	  end

	  def score_card_export_file_name(profile_id = nil)
	  	if profile_id.nil?
	  		return "all_franchises_score_card_export.csv"
	  	else
		    return "owner_#{profile_id}_score_card_export.csv"
		   end
	  end

	  def score_card_export_notification(profile_id = nil)
	    return "Your export file can be downloaded from http://www.kidscloset.biz/assets/1/#{self.score_card_export_file_name(profile_id)}"
	  end
	end
end
