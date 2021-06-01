class SubCategoryDrop < Liquid::Drop
  def initialize(sub_category_name, sale_number, category_number)
    @sub_category_name = sub_category_name 
    @sale_number = sale_number
    @category_number = category_number
  end

  def name
    @sub_category_name
  end

  def url_name
    CGI.escape(@sub_category_name)
  end
end