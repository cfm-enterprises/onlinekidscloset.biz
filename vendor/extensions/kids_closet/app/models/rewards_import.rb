class RewardsImport < ActiveRecord::Base
  belongs_to :sale
  belongs_to :site_asset
  has_many :rewards_earnings, :dependent => :destroy

  acts_as_site_member

  def validate
    errors.add(:rewards_date, "must be within the dates of the sale") if (rewards_date < sale.start_date - 2 || rewards_date > sale.end_date + 5) && sale.tentative_date.blank?
    errors.add(:rewards_date, ": The sale must begin before you can start uploading sale data") if sale.start_date - 2 > Date.today 
  end
  
  def rewards_file_date
    self.rewards_date.strftime("%b %d, %Y")
  end
end
