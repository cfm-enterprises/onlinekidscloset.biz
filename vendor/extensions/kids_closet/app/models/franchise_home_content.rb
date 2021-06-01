class FranchiseHomeContent < ActiveRecord::Base
	belongs_to :franchise

	validates_uniqueness_of :franchise_id
	validates_presence_of :franchise_id

	acts_as_site_member

  def mini_content
    items = []
    items << ["owner_photo_content","Owner Photo", owner_photo_content]
    items << ["meet_the_owner_content","Meet the Owner", meet_the_owner_content]
    items << ["franchise_rewards_content","Franchise Awards", franchise_rewards_content]
    items
  end

end
