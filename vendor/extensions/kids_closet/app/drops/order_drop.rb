class OrderDrop < Liquid::Drop
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

  def item_number
    @order.consignor_inventory_id
  end

  def item_name
    @order.item_name
  end

  def item_select_name
    "item_#{item_number}"
  end

  def additional_information
    @order.consignor_inventory.nil? ? "Not Available" : @order.consignor_inventory.additional_information
  end

  def has_no_additional_information?
    additional_information.nil? || additional_information == "" || additional_information == "Not Available"
  end

  def has_additional_information?
    !has_no_additional_information?
  end

  def price
    @order.item_price
  end

  def size
    @order.consignor_inventory.nil? ? "Not Available" : @order.consignor_inventory.size
  end

  def has_no_size?
    size.nil? || size == "" || size == "Not Available"
  end

  def has_size?
    !has_no_size?
  end

  def sale_location
    @order.sale.franchise.franchise_name
  end

  def tax
    @order.sales_tax
  end
  
  def total_price
    @order.total_amount
  end
  
  def sale_date
    @order.purchased_at.strftime("%b %d, %Y")
  end

#This needs to be fixed for different time zones
  def reserved_until
    if [20, 42, 30, 19, 51, 17].include?(@order.sale.franchise.province_id)
      (@order.ordered_at + 3600).strftime("%I:%M %p")
    elsif [2].include?(@order.sale.franchise.province_id)
      (@order.ordered_at - 7200).strftime("%I:%M %p")
    elsif [4].include?(@order.sale.franchise.province_id)
      @order.ordered_at.strftime("%I:%M %p")
    else
      (@order.ordered_at + 7200).strftime("%I:%M %p")
    end
  end
  
  def has_asset?
    !@order.consignor_inventory.nil? && !@order.consignor_inventory.main_photo.nil?
  end

  def main_photo
    FeaturedPhotoDrop.new(@order.consignor_inventory.main_photo)
  end

  def seller_id
    @order.seller_id
  end

  def buyer_id
    @order.buyer_id
  end 

  def is_item_in_database?
    @order.consignor_inventory.not_nil?
  end

  def printed?
    if is_item_in_database?
      return @order.consignor_inventory.printed ? "(P)" : ""
    else
      ""
    end
  end


  def print_url
    "/customer/print_selected_tag/#{item_number}"
  end

  def delete_cart_item_url
    "/customer/delete_cart_item/#{id}"
  end

  def item_details_url
    "/consignors/item_detail?item_id=#{item_number}"
  end
end