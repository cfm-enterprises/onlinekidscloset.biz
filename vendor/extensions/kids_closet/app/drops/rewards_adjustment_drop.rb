class RewardsAdjustmentDrop < Liquid::Drop
  def initialize(adjustment)
    @adjustment = adjustment
  end

  def date
    @adjustment.created_at.strftime("%b %d, %Y")
  end
  
  def franchise
    @adjustment.franchise.franchise_name
  end
  
  def amount_earned
    @adjustment.amount
  end  
end