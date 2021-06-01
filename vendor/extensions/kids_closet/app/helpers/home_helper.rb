module HomeHelper
  def pdf_image_tag(image, options = {})
    options[:src] = File.expand_path(RAILS_ROOT) + '/public/assets/1/original/' + image
    tag(:img, options)
  end  
  
  def pdf_path(image)
   File.expand_path(RAILS_ROOT) + '/public/assets/1/original/' + image
  end 
end
