class Admin::SaleConsignorTimesController < ApplicationController

  #GET /admin/sales/:sale_id/consignor_times
  def index
    @sale = Sale.find(params[:sale_id])
    @sale_consignor_times = @sale.sale_consignor_times.paginate(:all, :conditions => ["internal = ?", false], :page => params[:page])
    @consignor_internal_time = @sale.sale_consignor_times.find(:first, :conditions => ["internal = ?", true])
    @internal_consignor_count = @consignor_internal_time.consignor_profiles.count(:id)
    session[:return_url] = request.request_uri
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  #GET /admin/sale/:sale_id/consignor_times/new/
  def new
    @sale_consignor_time = SaleConsignorTime.new
    @sale_consignor_time.sale_id = params[:sale_id]
    last_consignor_time = SaleConsignorTime.latest_consignor_time_for_sale(params[:sale_id])
    unless last_consignor_time.nil?
      @sale_consignor_time.date = last_consignor_time.date
      @sale_consignor_time.start_time = last_consignor_time.end_time
      @sale_consignor_time.end_time = last_consignor_time.end_time + (last_consignor_time.end_time - last_consignor_time.start_time)
      @sale_consignor_time.number_of_spots = last_consignor_time.number_of_spots
      
      # Set end time to midnight if the calculation forced the day to be the next day
      if @sale_consignor_time.end_time.day > @sale_consignor_time.start_time.day
        @sale_consignor_time.end_time = Time.utc(@sale_consignor_time.start_time.year, @sale_consignor_time.start_time.month, @sale_consignor_time.start_time.day, 23, 55, 00) 
      end
    end      
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /admin/sale/:sale_id/consignor_time/
  def create
    @sale_consignor_time = SaleConsignorTime.new(params[:sale_consignor_time])

    respond_to do |format|
      if @sale_consignor_time.save
        flash[:notice] = 'Consignor Drop Off Time was successfully created.'
        format.html { redirect_to(new_admin_sale_sale_consignor_time_url(@sale_consignor_time.sale)) }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  #GET /admin/sale/:sale_id/consignor_time/edit/:id
  def edit
    @sale_consignor_time = SaleConsignorTime.find(params[:id])
    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  # PUT /admin/sale/:sale_id/consignor_time/:id
  def update
    @sale_consignor_time = SaleConsignorTime.find(params[:id])

    respond_to do |format|
      if @sale_consignor_time.update_attributes(params[:sale_consignor_time])
        flash[:notice] = 'Consignor Drop Off Time was successfully updated.'
        if session[:return_url]
          format.html {redirect_to (session[:return_url])}
        else
          format.html { redirect_to(admin_sale_sale_consignor_times_url(@sale_consignor_time.sale)) }
        end
      else
        format.html { render :action => "edit" }
      end
    end
  end

  #GET /admin/sale_consignor/:id
  def show 
    @sale_consignor_time = SaleConsignorTime.find(params[:id])
    @sale = @sale_consignor_time.sale
    @consignor_profiles = @sale_consignor_time.consignor_profiles
    @sale_consignor_sign_up = SaleConsignorSignUp.new
    @sale_consignor_sign_up.sale_consignor_time_id = params[:id]
    @available_consignors = SaleConsignorSignUp.load_available_consignors(@sale_consignor_time)
    session[:return_url] = request.request_uri
    respond_to do |format|
      format.html # show.html.erb
    end
  end
  
  #GET /admin/sale_consignor/:id/print_consignor_list
  def print_consignor_list 
    @sale_consignor_time = SaleConsignorTime.find(params[:id])
    @consignor_profiles = @sale_consignor_time.consignor_profiles
    render :layout => false
  end

  # DELETE /admin/consignor_times/:id
  def destroy
    @sale_consignor_time = SaleConsignorTime.find(params[:id])
    @sale_consignor_time.destroy if !@sale_consignor_time.internal

    respond_to do |format|
      flash[:warning] = "Consignor Time was successfully deleted."
      if session[:return_url]
        format.html {redirect_to (session[:return_url])}
      else
        format.html { redirect_to(admin_sale_sale_consignor_times_url(@sale_consignor_time.sale)) }
      end
    end
  end  
end
