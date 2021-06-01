class FranchiseRewardsAdjustment < ActiveRecord::Base
	belongs_to :franchise
	belongs_to :rewards_profile

	attr_accessor :rewards_number
	attr_accessor :rewards_number_confirmation

	before_validation :save_rewards_profile

	validates_presence_of :rewards_profile, :message => "could not be created"
	validates_presence_of :franchise
	validates_inclusion_of :amount, :in => (5..100).step(5), :message => "Amount should be a multiple of $5.00 not greater than $100"

	acts_as_site_member

	def validate
		errors.add(:rewards_number, "must be the same as the rewards number confirmation") if rewards_number.not_nil? && rewards_number_confirmation.not_nil? && rewards_number.to_i != rewards_number_confirmation.to_i
	end

	def customer_name
		rewards_profile.profile.nil? ? "Not Claimed" : rewards_profile.profile.full_name
	end

	def self.amount_options
		options = []
		for amount in (5..100).step(5)
			options << amount
		end
		return options
	end

	protected

	def save_rewards_profile
		if rewards_profile.nil?
			rewards_profile = RewardsProfile.find_by_rewards_number(rewards_number)
			if rewards_profile.nil?
				rewards_profile = RewardsProfile.new
				rewards_profile.rewards_number = rewards_number
				rewards_profile.rewards_number_confirmation = rewards_number_confirmation.to_i
				self.rewards_profile = rewards_profile if rewards_profile.save
			else
				self.rewards_profile = rewards_profile
			end
		end
	end
end
