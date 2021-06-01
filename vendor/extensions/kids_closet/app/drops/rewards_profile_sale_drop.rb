class RewardsProfileSaleDrop < Liquid::Drop
  def initialize(profile, sale)
    @profile = profile
    @sale = sale
  end

  def season
    @sale.sale_season.season_name
  end
  
  def franchise
    @sale.franchise.franchise_name
  end
  
  def primary_rewards_profile
    @profile.primary_rewards_profile
  end
  
  def amount_purchased
    primary_rewards_profile.amount_purchased_in_sale(@sale)
  end
  
  def rewards_earned
    RewardsProfile.rewards_for_total_amount(amount_purchased)
  end
end