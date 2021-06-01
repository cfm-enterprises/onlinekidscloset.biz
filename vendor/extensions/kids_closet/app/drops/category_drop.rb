class CategoryDrop < Liquid::Drop
  def initialize(category_name, sale_number)
    @category_name = category_name 
    @sale_number = sale_number
  end

  def name
    @category_name
  end

  def category_number
    ConsignorInventory.category_number_from_name(@category_name)
  end

  def category_sale_link
    "/sale/online_sale?sale_id=#{@sale_number}&category=#{category_number}"
  end

  def test_category_sale_link
    "/sale/featured_items?sale_id=#{@sale_number}&category=#{category_number}"
  end

  def sub_categories
    rvalue = []
    ConsignorInventory.sub_category_array(@category_name).each do |sub_category|
      rvalue << SubCategoryDrop.new(sub_category, @sale_number, category_number)
    end 
    rvalue     
  end

  def has_sub_categories?
    !sub_categories.empty?
  end

  def sizes
    rvalue = []
    ConsignorInventory.size_array(@category_name).each do |size|
      rvalue << SizeDrop.new(size, @sale_number, category_number)
    end 
    rvalue     
  end

  def has_sizes?
    !sizes.empty?
  end
end