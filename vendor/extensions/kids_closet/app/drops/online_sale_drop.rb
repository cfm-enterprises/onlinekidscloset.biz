class OnlineSaleDrop < Liquid::Drop
  include WillPaginate::Liquidized::ViewHelpers
  def initialize(sale, profile)
    @sale = sale
    @profile = profile
  end

  def sale_number
    @sale.id
  end

  def franchise_number
    @sale.franchise_id
  end

  def title
    "#{@sale.franchise.franchise_name} Kids Consignment Online Sale"
  end

  def sale_title
    @sale.sale_title
  end

  def orders
    @sale.orders.find(:all, :conditions => ["seller_id = ?", @profile.id])
  end  

  def number_of_items_sold
    orders.length
  end

  def total_sold
    return 0 if number_of_items_sold == 0
    value = 0
    for order in orders
      value += order.item_price
    end
    value
  end

  def total_tax
    return 0 if number_of_items_sold == 0
    value = 0
    for order in orders
      value += order.sales_tax
    end
    value
  end

  def total_amount
    total_sold + total_tax
  end
end