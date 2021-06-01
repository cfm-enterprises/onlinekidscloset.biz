class PayPalOrderDrop < Liquid::Drop
  def initialize(order)
    @order = order
  end

  def id
    @order.id
  end

  def completed?
    @order.purchased_at.not_nil?
  end

  def order_number
    @order.id
  end

  def orders
    rvalue = []
    for item_ordered in @order.orders
      rvalue << OrderDrop.new(item_ordered)
    end
    rvalue
  end

  def sub_total
    @order.sub_total
  end

  def sales_tax
    @order.sales_tax
  end

  def total
    @order.total_amount
  end

  def order_description
    @order.order_description
  end

  def pay_pal_button_description
    @order.button_description
  end

  def pay_pal_email
    @order.pay_pal_email  
  end

  def paypal_success_url
    "https://www.kidscloset.biz/customer/complete_purchase/#{id}"
  end

  def paypal_cancel_url
    "https://www.kidscloset.biz/consignors/check_out"
  end

  def cancel_order_url
    "/customer/cancel_purchase/#{id}"
  end

  def return_to_sale_url 
    "/sale/online_sale?sale_id=#{@order.sale.franchise_id}"
  end
end