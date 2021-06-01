class FranchisePhotoDrop < Liquid::Drop
  def initialize(franchise_photo)
    @franchise_photo = franchise_photo
  end
  
  def caption
    @franchise_photo.caption
  end
  
  def asset_link
  	@franchise_photo.site_asset.nil? ? @franchise_photo.asset_file_name : @franchise_photo.site_asset.asset_file_name
  end
  
end