class SaleProvinceDrop < Liquid::Drop
  def initialize(province)
    @province = province
  end
  
  def province
    @province.name
  end
  
  def province_code
    @province.code
  end
  
  def sales_for_province_url
    "/find_sale?province_id=#{@province.id}"
  end
  
  def province_sales
    sales = Sale.find(:all, :joins => :franchise, :conditions => ["sales.active = ? AND franchises.province_id = ?", true, @province.id], :order => "franchises.franchise_name, sales.start_date")
    rvalue = []
    sales.each do |sale|
      rvalue << SaleDrop.new(sale, nil)
    end
    rvalue
  end
end