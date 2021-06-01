module KidsCloset
  module SiteDropMixin

    def sale
      sale = Sale.find(1)
      SaleDrop.new(sale, nil)
    end

    def site_sales
      Sale.find(:all, :joins => [:franchise => :province], :conditions => ["active = ?", true], :order => "provinces.name, franchises.franchise_name, sales.start_date").map { |sale| SaleDrop.new(sale, nil) }
    end

    def category_javascript
      ConsignorInventory.backend_category_javascript
    end
        
    def site_provinces
      provinces = Province.find(:all, :select => "DISTINCT provinces.id", :joins => " INNER JOIN franchises f ON f.province_id = provinces.id", :order => "provinces.name")
      rvalue = []
      provinces.each do |province|
        rvalue << SaleProvinceDrop.new(Province.find(province.id)) if Sale.find(:first, :joins => :franchise, :conditions => ["sales.active = ? AND franchises.province_id = ?", true, province]).not_nil?
      end
      rvalue      
    end
  end
end