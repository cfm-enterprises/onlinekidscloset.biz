class SizeDrop < Liquid::Drop
  def initialize(size_name, sale_number, category_number)
    @size_name = size_name 
    @sale_number = sale_number
    @category_number = category_number
  end

  def name
    @size_name
  end

  def url_name
    CGI.escape(@size_name)
  end
end