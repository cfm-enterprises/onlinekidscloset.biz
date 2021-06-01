class DropOffTimeDrop < Liquid::Drop
  def initialize(time)
    @time = time
  end

  def date
    @time.date.strftime("%b %d, %Y")
  end
  
  def start_time
    @time.start_time.strftime("%I:%M %p")
  end
  
  def end_time
    @time.end_time.strftime("%I:%M %p")
  end
  
  def spots_left
    @time.spots_left
  end

  def sign_up_link
    "/customer/select_drop_off_time/#{@time.id}"
  end
end