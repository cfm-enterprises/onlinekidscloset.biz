class RewardsEarning < ActiveRecord::Base
  belongs_to :rewards_profile
  belongs_to :sale
  belongs_to :rewards_import
  
  acts_as_site_member

  validates_presence_of :rewards_profile_id, :sale_id, :amount_applied
  validates_numericality_of :amount_applied, :greater_than => 0
  
  def validate
    unless rewards_profile_id.nil? || rewards_profile.profile.nil? || sale_id.nil?  || amount_applied.nil?
      rewards_earned = rewards_profile.rewards_for_franchise(sale.franchise)
      amount_already_redeamed = RewardsEarning.earnings_by_profile_and_franchise(rewards_profile.profile, sale.franchise_id)
      errors.add(:amount_applied, " is more than the user has earned") if (amount_already_redeamed + amount_applied) > rewards_earned
    end
  end

  class << self
    def earnings_by_profile_and_franchise(profile, franchise_id)
      reward_profiles = profile.rewards_profiles
      total_amount = 0
      for reward_profile in reward_profiles
        total_amount += earnings_by_card(reward_profile, franchise_id)
      end
      return total_amount
    end
    
    def earnings_by_card(rewards_profile, franchise_id)
      rewards_profile.rewards_earnings.sum(:amount_applied, :include => :sale, :conditions => ["sales.franchise_id = ?", franchise_id])
    end
  end  

end
