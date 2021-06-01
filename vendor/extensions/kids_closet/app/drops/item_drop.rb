class ItemDrop < Liquid::Drop
  def initialize(item)
    @item = item
  end

  def id
    @item.id
  end

  def sold?
    @item.status
  end

  def item_number
    @item.id
  end

  def description
    @item.item_description
  end

  def additional_information
    @item.additional_information
  end

  def has_no_additional_information?
    additional_information.nil? || additional_information == ""
  end

  def has_additional_information?
    !has_no_additional_information?
  end

  def price
    @item.price
  end

  def discount_50_price
   price * 0.50
  end

  def discount_25_price
   price * 0.75
  end

  def size
    @item.size  
  end

  def category
    @item.category_name
  end

  def sub_category
    @item.sub_category
  end

  def has_sub_category?
    !sub_category.empty_or_nil?
  end

  def formatted_category
    string = category
    string += " / #{sub_category}" if has_sub_category?
    string
  end

  def has_no_size?
    size.nil? || size == ""
  end

  def has_size?
    !has_no_size?
  end

  def allow_discount?
    @item.last_day_discount ? "Yes" : "No"
  end

  def was_discounted?
    @item.discounted_at_sale ? "Yes" : "No"
  end
  
  def donate_item?
    @item.donate
  end
  
  def printed?
    @item.printed ? "(P)" : ""
  end
  
  def item_select_name
    "item_#{@item.id}"
  end
  
  def sale_location
    @item.sale.franchise.franchise_name
  end

  def sale_price
    @item.sale_price
  end
  
  def tax
    @item.tax_collected
  end
  
  def total_price
    @item.total_price
  end
  
  def sale_date
    @item.sale_date.strftime("%b %d, %Y")
  end
  
  def transaction_number
    @item.transaction_number
  end
  
  def is_donated?
    @item.donate_date.not_nil? && @item.donate_date.not_blank?
  end

  def donated_date
    @item.donate_date.strftime("%b %d, %Y")
  end

  def is_featured?
    @item.featured_item
  end
  
  def bring_to_sale?
    @item.bring_to_sale
  end

  def active_flag
    bring_to_sale? ? "true" : "false"
  end

  def edit_url
    "/consignors/item?consignor_inventory_id=#{@item.id}&page=#{page}&active=#{bring_to_sale?}"
  end

  def print_url
    "/customer/print_selected_tag/#{@item.id}"
  end
  
  def donate_url
    "/customer/donate_item/#{@item.id}?page=#{page}"
  end
  
  def donate_inactive_url
    "/customer/donate_inactive_item/#{@item.id}?page=#{page}"    
  end
  
  def delete_url
    "/customer/destroy_item/#{@item.id}?page=#{page}"
  end
  
  def delete_inactive_url
    "/customer/destroy_inactive_item/#{@item.id}?page=#{page}"
  end

  def make_active_url
    "/customer/make_active_item/#{@item.id}?page=#{page}"    
  end
    
  def make_inactive_url
    "/customer/make_inactive_item/#{@item.id}?page=#{page}"    
  end

  def make_not_featured_url
    "/customer/make_item_not_featured/#{@item.id}?page=#{page}"  
  end

  def more_details_url
    "/consignors/item?consignor_inventory_id=#{@item.id}&page=#{page}"
  end
    
  def page
    page = @context.registers[:controller].send(:params)[:page]
    return page.empty_or_nil? ? 1 : page
  end

  def item_status
    return "Sold" if sold?
    return "Donated" if is_donated?
    return "Coming to Sale" if bring_to_sale?
    return "Not Coming"
  end

  def has_asset?
    !@item.main_photo.nil?
  end

  def main_photo
    FeaturedPhotoDrop.new(@item.main_photo)
  end

  def number_of_photos
    @item.featured_photos.count
  end

  def featured_photos
    options = []
    for photo in @item.featured_photos
      options << FeaturedPhotoDrop.new(photo)
    end
    options
  end

  def sale_link
    "/customer/purchase_item_with_paypal/#{id}?franchise_id="
  end

  def sale_details_url 
    "/sale/sale_item_detail?item_id=#{id}&sale_id="
  end
end