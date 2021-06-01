class RewardProfileSearch < ActiveRecord::BaseWithoutTable
  
  column :phrase, :string, ""
  column :page, :integer, 1
  column :per_page, :integer, 25
  column :franchise_id, :integer

  def self.per_page_select_options
    [["25", "25"], ["50", "50"], ["100", "100"], ["250", "250"], ["500", "500"], ["1000", "1000"]]
  end

  def profiles
    franchise = Franchise.find(franchise_id)
    franchise.rewards_profiles_search(like_conditions, phrase).paginate(
      :per_page => per_page,
      :page => page
    )
  end

  private

  def like_conditions
    [
      "rewards_profiles.rewards_number LIKE ?",
      "profiles.email LIKE ?",
      "profiles.first_name LIKE ?",
      "profiles.last_name LIKE ?"
    ]
  end

end
