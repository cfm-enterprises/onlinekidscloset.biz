module KidsClosetFilters
  include ActionView::Helpers::NumberHelper
#  def sale_detail_by_id(id, assign)
#    sale = Sale.find(id)
#    sale_drop = SaleDrop.new(sale, nil)
#    assign_to(sale_drop, assign)
#    nil
#  end 
  def sale_detail_by_id(franchise_id, assign, category=nil, sub_category=nil, size=nil, search_term=nil)
    sale = Sale.current_active_sale(franchise_id)
    sale_drop = SaleDrop.new(sale, nil, category, sub_category, size, search_term)
    assign_to(sale_drop, assign)
    nil
  end
  
  def item_detail_by_id(item_id, assign)
    item_id = item_id.to_i
    if item_id != 0
      item = ConsignorInventory.find(item_id)
      item_drop = ItemDrop.new(item)
      assign_to(item_drop, assign)
    end
    nil
  end

  def order_detail_by_id(order_id, assign)
    order_id = order_id.to_i
    if order_id != 0
      order = Order.find(order_id)
      order_drop = OrderDrop.new(order)
      assign_to(order_drop, assign)
    end
    nil
  end

  def pay_pal_order_detail_by_id(order_id, assign)
    order_id = order_id.to_i
    if order_id != 0
      order = PayPalOrder.find(order_id)
      order_drop = PayPalOrderDrop.new(order)
      assign_to(order_drop, assign)
    end
    nil
  end

  def province_detail_from_id(id, assign)
    unless id.empty_or_nil?      
      province = Province.find(id)
      province_drop = SaleProvinceDrop.new(province)
      assign_to(province_drop, assign)
    end
    nil
  end      

  def currency(price)
    number_to_currency(price)
  end
  
  def get_update_url(page, assign, active, item_id)
    page = 1 if page.empty_or_nil?
    update_url = active == "true" ? "/consignors/inventory?page=#{page}&x=y#I#{item_id}" : "/consignors/inactive_inventory?page=#{page}&x=y#I#{item_id}"
    assign_to(update_url, assign)
    nil
  end

  def item_search(search_term, assign, profile_id)
    profile = Profile.find(profile_id)
    items = profile.item_search(search_term)
    options = []
    for item in items
      options << ItemDrop.new(item)
    end
    assign_to(options, assign)
  end

  def item_search_count(search_term, assign, profile_id)
    profile = Profile.find(profile_id)
    items = profile.item_search(search_term)
    assign_to(items.length, assign)
  end

  def featured_item_search(search_term, assign, profile_id)
    profile = Profile.find(profile_id)
    items = profile.featured_item_search(search_term)
    options = []
    for item in items
      options << ItemDrop.new(item[0])
    end
    assign_to(options, assign)
  end

  def featured_item_search_count(search_term, assign, profile_id)
    profile = Profile.find(profile_id)
    items = profile.featured_item_search(search_term)
    assign_to(items.length, assign)
  end

  def sale_featured_item_search(search_term, assign, sale_id, category=nil, sub_category=nil, size=nil)
    sale = Franchise.find(sale_id).active_sale
    items = sale.featured_item_search(search_term, category, sub_category, size)
    options = []
    for item in items
      options << ItemDrop.new(item)
    end
    assign_to(options, assign)
  end

  def sale_featured_item_search_count(search_term, assign, sale_id, category=nil, sub_category=nil, size=nil)
    sale = Franchise.find(sale_id).active_sale
    items = sale.featured_item_search(search_term, category, sub_category, size)
    assign_to(items.length, assign)
  end  

  def get_volunteer_job_success_url(job_id, assign)
    update_url = "/customer/select_volunteer_job/#{job_id}"
    assign_to(update_url, assign)
  end

  def get_sales_for_zip_code(zip_code, assign)
    latitude, longitude = ZipCode.return_coordinates(zip_code)
    matching_sales = Sale.active_sales.near([latitude, longitude], 50)
    options = []
    for sale in matching_sales
      options << SaleDrop.new(sale, nil)
    end
    assign_to(options, assign)
  end

  def button_to_delete(text, path, message)
    "<a class='btn' onclick=\"#{delete_on_click(message)}\" href=\"#{path}\">#{text}</a>"
  end

  def category_from_number(category_number, assign, franchise_number)
    category_name = ConsignorInventory.category_name_from_number(category_number.to_s)
    category = CategoryDrop.new(category_name, franchise_number)
    assign_to(category, assign)
  end

  private
  
  def delete_on_click(message)
    rvalue = <<-MSG
      if (confirm('#{message}')) {
        var f = document.createElement('form');
        f.style.display = 'none';
        this.parentNode.appendChild(f);
        f.method = 'POST';
        f.action = this.href;
        var m = document.createElement('input');
        m.setAttribute('type', 'hidden');
        m.setAttribute('name', '_method');
        m.setAttribute('value', 'delete');
        f.appendChild(m);
        var s = document.createElement('input');
        s.setAttribute('type', 'hidden');
        s.setAttribute('name', 'authenticity_token');
        s.setAttribute('value', '#{@context.registers['form_authenticity_token']}');
        f.appendChild(s);
        f.submit();
      };
      return false;"
    MSG
  end

end