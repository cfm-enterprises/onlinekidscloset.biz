class TransactionImport < ActiveRecord::Base
  belongs_to :sale
  belongs_to :site_asset
  has_many :items_sold, :class_name => "ConsignorInventory", :dependent => :nullify
  
  after_create :possibly_update_items_coming_to_sale

  acts_as_site_member

  validates_numericality_of :extra_income, :greater_than_or_equal_to => 0 

  def validate
    errors.add(:report_date, "must be within the dates of the sale") if (report_date < sale.start_date - 2 || report_date > sale.end_date + 5) && sale.tentative_date.blank?
    errors.add(:report_date, ": The sale must begin before you can start uploading sale data") if sale.start_date - 2 > Date.today 
  end

  def report_dates
    self.report_date.strftime("%b %d, %Y")
  end

  protected

  def possibly_update_items_coming_to_sale
    if sale.items_coming.nil?
      sale.items_coming = sale.number_of_possible_sale_items
      sale.save
    end
  end

end
