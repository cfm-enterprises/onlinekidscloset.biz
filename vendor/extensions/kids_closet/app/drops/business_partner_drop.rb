class BusinessPartnerDrop < Liquid::Drop
  def initialize(business_partner)
    @business_partner = business_partner
  end

  def title
    @business_partner.partner_title
  end

  def url
    @business_partner.partner_url    
  end

  def full_url
    @business_partner.link_url    
  end

  def description
    @business_partner.partner_description    
  end
  
  def asset_link
    "/assets/1/original/#{@business_partner.site_asset.asset_file_name}"
  end
  
  def has_asset?
    @business_parnter.site_asset.not_nil?
  end
end