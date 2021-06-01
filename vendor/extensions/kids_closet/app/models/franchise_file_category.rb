class FranchiseFileCategory < ActiveRecord::Base
  has_many :franchise_files, :include => :site_asset, :order => "site_assets.display_name", :dependent => :destroy
  
  acts_as_site_member

  validates_presence_of :title
  validates_uniqueness_of :title
end
