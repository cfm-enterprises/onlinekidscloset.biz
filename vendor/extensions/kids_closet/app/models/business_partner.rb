class BusinessPartner < ActiveRecord::Base
  belongs_to :sale
  belongs_to :site_asset

  acts_as_site_member
  
  validates_presence_of :sale_id, :sort_index, :partner_title, :partner_url, :partner_description
  validates_uniqueness_of :partner_title, :scope => :sale_id
  validates_numericality_of :sort_index, :greater_than => 0, :only_integer => true
  

  def link_url
    "http://#{partner_url}"
  end
  
end
