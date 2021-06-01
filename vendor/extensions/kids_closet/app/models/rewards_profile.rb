class RewardsProfile < ActiveRecord::Base
  belongs_to :profile
  has_many :items_purchased, :class_name => "ConsignorInventory", :dependent => :nullify
  has_many :rewards_earnings, :dependent => :destroy
  has_many :rewards_profile_sale_results, :dependent => :destroy
  has_many :sales, :through => :rewards_profile_sale_results, :order => "sales.start_date"
  has_many :franchise_rewards_adjustments, :dependent => :destroy

  acts_as_site_member

  before_save :inactivate_old_card_if_primary

  attr_accessor :rewards_number_confirmation

  validates_uniqueness_of :rewards_number
  validates_presence_of :rewards_number
  validates_presence_of :rewards_number_confirmation, :on => :create
  validates_confirmation_of :rewards_number, :if => :new_record?
  validates_numericality_of :rewards_number, :greater_than => 9999999, :only_integer => true, :message => "Must be 8 digits long."
  validates_numericality_of :rewards_number, :less_than => 100000000, :only_integer => true, :message => "Must be 8 digits long."

  class << self
    def sales_for_profile(profile)
      reward_profiles = profile.rewards_profiles
      return [] if reward_profiles.empty?
      sales = []
      for reward_profile in reward_profiles
        sales = sales | reward_profile.sales
      end
      return sales.empty? ? [] : sales.sort! {|a, b| a.start_date <=> b.start_date}
    end
    
    def franchises_for_profile(profile)
      reward_profiles = profile.rewards_profiles.find(:all)
      return [] if reward_profiles.empty?
      test_ids = []
      franchise_ids = []
      for reward_profile in reward_profiles
        franchise_ids = franchise_ids | reward_profile.sales.find(:all, :select => "DISTINCT sales.franchise_id").map(&:franchise_id)
      end
      return franchise_ids.empty? ? [] : Franchise.find(:all, :order => "franchise_name", :conditions => ["id in (?)", franchise_ids])
    end

    def rewards_for_total_amount(amount)
      number_of_rewards = amount.to_i / 100
      return number_of_rewards * 5
    end
  
    def current_primary_card(profile_id)
      return find(:first, :conditions => ["profile_id = ? AND primary_card = ?", profile_id, true])
    end

    def reward_amount_drop_down_options(max_amount)
      rvalue = []
      while max_amount > 0
        rvalue << [max_amount, max_amount]
        max_amount -= 5
      end
      rvalue
    end

    def rewards_profiles
      return find(:all, :conditions => ["profile_id IS NULL OR primary_card = ?", true], :order => "rewards_number")
    end
  end
  
  def single_card_rewards_for_franchise(franchise)
    amount_earned = 0
    for sale in franchise.sales
      amount_earned += RewardsProfile.rewards_for_total_amount(sale.amount_purchased_by_rewards_profile(self.id))
    end
    amount_earned += franchise_rewards_adjustments.sum(:amount, :conditions => ["franchise_id = ?", franchise.id])
    return amount_earned    
  end
    
  def amount_purchased(sale_id)
    items_purchased.sum(:sale_price, :conditions => ["sale_id = ?", sale_id])
  end

  def amount_purchased_in_sale(sale)
    amount_purchased = 0
    if profile.nil? 
      amount_purchased = sale.amount_purchased_by_rewards_profile(self.id)
    else
      for reward_profile in profile.rewards_profiles
        amount_purchased += sale.amount_purchased_by_rewards_profile(reward_profile.id)
      end
    end
    return amount_purchased
  end
  
  def rewards_for_franchise(franchise)
    amount_earned = 0
    for sale in franchise.sales
      amount_earned += RewardsProfile.rewards_for_total_amount(amount_purchased_in_sale(sale)) 
    end
    for reward_profile in profile.rewards_profiles
      amount_earned += reward_profile.franchise_rewards_adjustments.sum(:amount, :conditions => ["franchise_id = ?", franchise.id])
    end
    return amount_earned    
  end

  def has_rewards_in_franchise(franchise)
    for sale in franchise.sales
      return true if RewardsProfile.rewards_for_total_amount(amount_purchased_in_sale(sale)) > 0
    end
    return false  
  end

  private
  
    def inactivate_old_card_if_primary
      if self.primary_card
        last_primary_card = RewardsProfile.current_primary_card(self.profile_id)
        unless last_primary_card.nil? || last_primary_card.id == self.id
          last_primary_card.primary_card = false
          last_primary_card.rewards_number_confirmation = last_primary_card.rewards_number
          last_primary_card.save
        end
      end
    end
  
end
