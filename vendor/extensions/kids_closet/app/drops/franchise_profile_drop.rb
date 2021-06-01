class FranchiseProfileDrop < Liquid::Drop
  def initialize(franchise_profile, user)
    @franchise_profile = franchise_profile
    @user = user
  end
  
  def franchise_name
    @franchise_profile.franchise.franchise_name
  end
  
  def franchise_number
    @franchise_profile.franchise_id
  end
  
  def active_sale
    sale = Sale.current_active_sale(@franchise_profile.franchise_id)
    SaleDrop.new(sale, @user)
  end
  
  def is_consignor?
    @franchise_profile.consignor
  end
  
  def is_volunteer?
    @franchise_profile.volunteer
  end
  
  def is_on_mailing_list?
    @franchise_profile.mailing_list
  end
  
  def consign_url
    "/sale/consign_register?sale_id=#{franchise_number}"        
  end
  
  def volunteer_url
    "/consignors/helper_jobs?sale_id=#{franchise_number}"    
  end
  
  def volunteer_2017_url
    "/sale/helpers_info?sale_id=#{franchise_number}#table_data_volunteer"
  end

  def cancel_url
    "/customer/cancel_inactive_franchise/#{franchise_number}"            
  end
  
  def has_active_sale?
    active_sale.not_nil?
  end

end