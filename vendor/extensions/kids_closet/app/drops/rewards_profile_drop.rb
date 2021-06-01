class RewardsProfileDrop < Liquid::Drop
  def initialize(reward_card)
    @reward_card = reward_card
  end

  def rewards_number
    @reward_card.rewards_number
  end
  
  def is_primary?
    @reward_card.primary_card ? "Yes" : "No"
  end
  
  def make_primary_link
    "/customer/make_card_primary/#{@reward_card.id}"
  end  
end