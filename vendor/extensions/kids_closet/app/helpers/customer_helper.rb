module CustomerHelper
  def pdf_image_tag(image, options = {})
    options[:src] = File.expand_path(RAILS_ROOT) + '/public/assets/1/original/' + image
    tag(:img, options)
  end  

  def bar_code_image_tag(image, options = {})
    options[:src] = File.expand_path(RAILS_ROOT) + '/public/assets/1/' + image
    tag(:img, options)
  end  
end
