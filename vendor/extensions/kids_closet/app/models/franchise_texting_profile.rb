class FranchiseTextingProfile < ActiveRecord::Base
	belongs_to :franchise

	acts_as_site_member

	validates_presence_of :franchise_id, :phone
	validates_uniqueness_of :phone, :scope => :franchise_id
	validates_length_of :phone, :minimum => 10
end
