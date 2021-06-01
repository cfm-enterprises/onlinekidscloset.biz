class SaleSeason < ActiveRecord::Base
  has_many :sales, :order => "start_date", :dependent => :nullify
  has_many :items_sold, :class_name => "ConsignorInventory", :through => :sales, :source => :items_sold

  acts_as_site_member

  validates_presence_of :start_date, :end_date, :season_name
  validates_uniqueness_of :season_name 
  
  def validate
    errors.add(:end_date, " Must be greated than the Start Date") if end_date.not_nil? && start_date.not_nil? && end_date < start_date
  end

  def season_dates
    "#{self.start_date.strftime("%B %d, %Y")} - #{self.end_date.strftime("%B %d, %Y")}"
  end  

  def clear_sold_items
    if SaleSeason.current_sale_season_id != self.id
      for item in items_sold
        item.destroy
      end
      for item in ConsignorInventory.donated_items
        item.destroy
      end
    end
    return true
  end

  def update_items_not_coming_to_sale
    if SaleSeason.current_sale_season_id != self.id  
      for item in unsold_items_for_season
        item.bring_to_sale = false
        item.save
      end
    end
    return true
  end

  def update_new_consignors
    for sale in sales
      for new_consignor in sale.consignor_profiles.find(:all, :conditions => ["franchise_profiles.new_consignor = ? AND franchise_profiles.created_at < ?", true, sale.end_date.to_time])
        new_consignor.franchise_profile.new_consignor = false
        new_consignor.franchise_profile.save
      end
    end
  end
    
  def last_sale_date
    sales.maximum(:end_date)
  end

  def unsold_items_for_season
    ConsignorInventory.find(:all, :conditions => ["status = ? AND donate_date IS NULL AND bring_to_sale = ? AND created_at <= ?", false, true, last_sale_date.to_time])
  end

  class << self
    def latest_sale_season
      return find(:first, :order => "start_date DESC")
    end

    def current_sale_season
      return find(:first, :conditions => ["start_date <= ? AND end_date >= ?", Date.today, Date.today], :order => "start_date DESC")
    end

    def current_sale_season_id
      current_sale_season = SaleSeason.current_sale_season
      current_sale_season.nil? ? 0 : current_sale_season.id
    end

    def past_sale_seasons
      return find(:all, :conditions => ["end_date < ? AND season_name NOT LIKE ?", Date.today, "%Holiday%"], :order => "end_date DESC")
    end

    def prior_season
      return past_sale_seasons[0]
    end

    def second_prior_season
      return past_sale_seasons[1]
    end

    def third_prior_season
      return past_sale_seasons[2]
    end
  end
end
