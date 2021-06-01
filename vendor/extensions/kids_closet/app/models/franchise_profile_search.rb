class FranchiseProfileSearch < ActiveRecord::BaseWithoutTable
  
  column :phrase, :string, ""
  column :page, :integer, 1
  column :per_page, :integer, 25
  column :franchise_id, :integer

  def self.per_page_select_options
    [["25", "25"], ["50", "50"], ["100", "100"], ["250", "250"], ["500", "500"], ["1000", "1000"]]
  end

  def profiles
    FranchiseProfile.paginate(
      :conditions => conditions,
      :per_page => per_page,
      :order => order,
      :page => page,
      :joins => " INNER JOIN (profiles LEFT JOIN users ON profiles.id = users.profile_id) ON franchise_profiles.profile_id = profiles.id"
    )
  end

  private

  def conditions
    rvalue = nil
    if Site.current_site_id.not_nil? && !phrase.empty_or_nil?
      rvalue = ["franchise_profiles.franchise_id = ? AND (#{like_conditions.join(" OR ")})"]
      rvalue << self.franchise_id
      like_conditions.length.times do
        rvalue << "%#{phrase}%"
      end
    elsif Site.current_site_id.not_nil?
      rvalue = ["franchise_profiles.franchise_id = ?", self.franchise_id]      
    end
    rvalue
  end

  def order
    "profiles.last_name, profiles.first_name"
  end

  def like_conditions
    [
      "users.login LIKE ?",
      "profiles.email LIKE ?",
      "profiles.first_name LIKE ?",
      "profiles.last_name LIKE ?",
      "franchise_profiles.profile_id LIKE ?"
    ]
  end

end
