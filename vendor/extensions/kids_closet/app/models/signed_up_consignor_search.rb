class SignedUpConsignorSearch < ActiveRecord::BaseWithoutTable
  
  column :phrase, :string, ""
  column :page, :integer, 1
  column :per_page, :integer, 25
  column :sale_id, :integer
  column :sort_order, :string, ""

  def self.per_page_select_options
    [["25", "25"], ["50", "50"], ["100", "100"], ["250", "250"], ["500", "500"], ["1000", "1000"]]
  end

  def profiles
    sale = Sale.find(self.sale_id)
    if self.phrase.empty_or_nil?
      sale.consignor_profiles.paginate(
        :per_page => per_page,
        :order => order,
        :page => page
      )
    else
      sale.consignor_profiles.paginate(
        :conditions => conditions,
        :per_page => per_page,
        :order => order,
        :page => page
      )
    end
  end

  def print_profiles
    sale = Sale.find(self.sale_id)
    if self.phrase.empty_or_nil?
      sale.consignor_profiles.find(:all, :order => order)
    else
      sale.consignor_profiles.find(:all, :conditions => conditions, :order => order)
    end
  end

  private

  def conditions
    rvalue = nil
    if Site.current_site_id.not_nil? && !phrase.empty_or_nil?
      rvalue = ["(#{like_conditions.join(" OR ")})"]
      like_conditions.length.times do
        rvalue << "%#{phrase}%"
      end
    end
    rvalue
  end

  def order
    self.sort_order.blank? ? "profiles.last_name, profiles.first_name" : "profiles.#{self.sort_order}"
  end

  def like_conditions
    [
      "profiles.email LIKE ?",
      "profiles.first_name LIKE ?",
      "profiles.last_name LIKE ?",
      "franchise_profiles.profile_id LIKE ?"
    ]
  end

end
