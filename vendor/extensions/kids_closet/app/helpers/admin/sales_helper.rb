module Admin::SalesHelper
  def pdf_image_tag(image, options = {})
    options[:src] = File.expand_path(RAILS_ROOT) + '/public/assets/1/original/' + image
    tag(:img, options)
  end  
end