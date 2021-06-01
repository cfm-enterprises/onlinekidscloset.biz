class VolunteerJobDrop < Liquid::Drop
  def initialize(job)
    @job = job
  end

  def number
    @job.id
  end

  def weekday
    @job.date.strftime("%A")
  end

  def date
    @job.date.strftime("%b %d, %Y")
  end
  
  def start_time
    @job.start_time.strftime("%I:%M %p")
  end
  
  def end_time
    @job.end_time.strftime("%I:%M %p")
  end
  
  def title
    @job.job_title
  end
  
  def description
    @job.job_description
  end
  
  def spots_left
    @job.spots_left
  end

  def none_traditional_job?
    @job.none_traditional_job
  end

  def sign_up_link
    "/customer/select_volunteer_job/#{@job.id}"
  end
  
  def cancel_link
    "/customer/cancel_volunteer_job/#{@job.id}"
  end
  
  def job_time_information
    "<b>#{date}, #{start_time} - #{end_time}</b>"    
  end

  def job_time_information_2017
    "#{date}, #{start_time} - #{end_time}"    
  end

  def new_volunteer_url
    "/sale/volunteer_register_new?sale_id=#{@job.sale.franchise_id}&job=#{@job.id}"
  end 
end