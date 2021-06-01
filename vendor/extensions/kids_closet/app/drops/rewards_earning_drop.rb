class RewardsEarningDrop < Liquid::Drop
  def initialize(earning)
    @earning = earning
  end

  def date
    @earning.created_at.strftime("%b %d, %Y")
  end
  
  def franchise
    @earning.sale.franchise.franchise_name
  end
  
  def season
    @earning.sale.sale_season.season_name
  end
  
  def amount_earned
    @earning.amount_applied
  end  
end