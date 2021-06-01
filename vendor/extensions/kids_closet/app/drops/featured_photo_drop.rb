class FeaturedPhotoDrop < Liquid::Drop
  def initialize(photo)
    @photo = photo
  end

  def asset_link
  	@photo.asset_file_name
  end

  def rotation_class
  	@photo.rotation_class
  end

  def rotate_clockwise_url
    "/customer/rotate_featured_photo_clockwise/#{@photo.id}?page=#{page}"    
  end

  def rotate_counter_clockwise_url
    "/customer/rotate_featured_photo_counter_clockwise/#{@photo.id}?page=#{page}"    
  end

  def remove_photo_url
    "/customer/delete_featured_photo/#{@photo.id}?page=#{page}"    
  end

  def page
    page = @context.registers[:controller].send(:params)[:page]
    return page.empty_or_nil? ? 1 : page
  end


end
