class SaleConsignorSignUpDrop < Liquid::Drop
  def initialize(sale_consignor_sign_up)
    @sale_consignor_sign_up = sale_consignor_sign_up
  end

  def sale_name
    @sale_consignor_sign_up.sale_name
  end

  def items_sold
    @sale_consignor_sign_up.items_sold    
  end

  def number_of_items_sold
    @sale_consignor_sign_up.quantity_sold    
  end

  def total_sales
    @sale_consignor_sign_up.total_sold    
  end

  def percentage
    @sale_consignor_sign_up.sale_percentage  
  end
  
  def advertisement_fee
    @sale_consignor_sign_up.advertisement_fee_paid
  end

  def fee_adjustment
    @sale_consignor_sign_up.fee_adjustment
  end

  def amount_earned
    @sale_consignor_sign_up.check_amount
  end
end