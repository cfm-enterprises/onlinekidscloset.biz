class Admin::SaleVolunteerTimesController < ApplicationController

  #GET /admin/sales/:sale_id/volunteer_times
  def index
    @sale = Sale.find(params[:sale_id])
    @sale_volunteer_times = @sale.sale_volunteer_times.paginate(:all, :page => params[:page])
    session[:return_url] = request.request_uri
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  #GET /admin/sale/:sale_id/volunteer_times/new/
  def new
    @sale_volunteer_time = SaleVolunteerTime.new
    @sale_volunteer_time.sale_id = params[:sale_id]
    last_volunteer_time = SaleVolunteerTime.latest_volunteer_time_for_sale(params[:sale_id])
    unless last_volunteer_time.nil?
      @sale_volunteer_time.date = last_volunteer_time.date
      @sale_volunteer_time.start_time = last_volunteer_time.end_time
      @sale_volunteer_time.end_time = last_volunteer_time.end_time + (last_volunteer_time.end_time - last_volunteer_time.start_time)
      @sale_volunteer_time.number_of_spots = last_volunteer_time.number_of_spots
      # Set end time to midnight if the calculation forced the day to be the next day
      if @sale_volunteer_time.end_time.day > @sale_volunteer_time.start_time.day
        @sale_volunteer_time.end_time = Time.utc(@sale_volunteer_time.start_time.year, @sale_volunteer_time.start_time.month, @sale_volunteer_time.start_time.day, 23, 55, 59) 
      end
    end      
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /admin/sale/:sale_id/volunteer_time/
  def create
    @sale_volunteer_time = SaleVolunteerTime.new(params[:sale_volunteer_time])

    respond_to do |format|
      if @sale_volunteer_time.save
        flash[:notice] = 'Helper Job was successfully created.'
        format.html { redirect_to(new_admin_sale_sale_volunteer_time_url(@sale_volunteer_time.sale)) }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  #GET /admin/sale/:sale_id/volunteer_time/edit/:id
  def edit
    @sale_volunteer_time = SaleVolunteerTime.find(params[:id])
  end

  # PUT /admin/sale/:sale_id/volunteer_time/:id
  def update
    @sale_volunteer_time = SaleVolunteerTime.find(params[:id])

    respond_to do |format|
      if @sale_volunteer_time.update_attributes(params[:sale_volunteer_time])
        flash[:notice] = 'Helper Job was successfully updated.'
        format.html { redirect_to(admin_sale_volunteer_time_url(@sale_volunteer_time)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def make_active
    @sale_volunteer_time = SaleVolunteerTime.find(params[:id])
    @sale_volunteer_time.draft_status = false
    respond_to do |format|
      if @sale_volunteer_time.save
        flash[:notice] = 'This Job is now Active'
        format.html { redirect_to(admin_sale_sale_volunteer_times_url(@sale_volunteer_time.sale)) }
      else
        format.html { render :action => "edit" }
      end
    end      
  end

  #GET /admin/sale_volunteer/:id
  def show 
    @sale_volunteer_time = SaleVolunteerTime.find(params[:id])
    @sale = @sale_volunteer_time.sale
    @volunteer_profiles = @sale_volunteer_time.volunteer_profiles
    @sale_volunteer_sign_up = SaleVolunteerSignUp.new
    @sale_volunteer_sign_up.sale_volunteer_time_id = params[:id]
    @available_volunteers = SaleVolunteerSignUp.load_available_volunteers(@sale_volunteer_time)
    session[:return_url] = request.request_uri
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def print_volunteer_list
    @sale_volunteer_time = SaleVolunteerTime.find(params[:id])
    @volunteer_profiles = @sale_volunteer_time.volunteer_profiles
    render :layout => false
  end
  
  # DELETE /admin/volunteer_times/:id
  def destroy
    @sale_volunteer_time = SaleVolunteerTime.find(params[:id])
    @sale_volunteer_time.destroy

    respond_to do |format|
      flash[:warning] = "Helper Job was successfully deleted."
      format.html { redirect_to(admin_sale_sale_volunteer_times_url(@sale_volunteer_time.sale)) }
    end
  end  
end
