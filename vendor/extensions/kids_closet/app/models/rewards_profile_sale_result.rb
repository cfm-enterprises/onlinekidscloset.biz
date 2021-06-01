class RewardsProfileSaleResult < ActiveRecord::Base
  belongs_to :sale
  belongs_to :rewards_profile

  acts_as_site_member
  
  validates_presence_of :rewards_profile_id, :sale_id, :amount_purchased
  validates_numericality_of :amount_purchased, :greater_than => 0, :message => " must be a valid number greater than 0"
  
end
