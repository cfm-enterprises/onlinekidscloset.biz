class RewardsProfileFranchiseDrop < Liquid::Drop
  def initialize(profile, franchise)
    @profile = profile
    @franchise = franchise
  end

  def franchise
    @franchise.franchise_name
  end
  
  def rewards_earned
    rewards_profile = @profile.primary_rewards_profile
    return rewards_profile.nil? ? 0 : rewards_profile.rewards_for_franchise(@franchise)
  end
   
  def rewards_used
    RewardsEarning.earnings_by_profile_and_franchise(@profile, @franchise.id)
  end
  
  def rewards_available
    rewards_earned - rewards_used
  end
end