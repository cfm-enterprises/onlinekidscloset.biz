class FranchiseFile < ActiveRecord::Base
  belongs_to :franchise_file_category
  belongs_to :site_asset
  
  acts_as_site_member

  validates_presence_of :franchise_file_category_id, :site_asset_id
  
end
