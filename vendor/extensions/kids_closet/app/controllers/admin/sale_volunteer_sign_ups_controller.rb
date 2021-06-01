class Admin::SaleVolunteerSignUpsController < ApplicationController

  def new
    respond_to do |format|
      format.html # new.html.erb
    end    
  end
  
  # post /admin/sale_volunteer_time
  def create
    @sale_volunteer_sign_up = SaleVolunteerSignUp.new(params[:sale_volunteer_sign_up])
    
    respond_to do |format|
      if @sale_volunteer_sign_up.save
        flash[:notice] = 'Helper Assigned to this time.'
        format.html { redirect_to (session[:return_url]) }
      else
        @sale_volunteer_time = @sale_volunteer_sign_up.sale_volunteer_time
        @available_volunteers = SaleVolunteerSignUp.load_available_volunteers(@sale_volunteer_time)
        format.html { render :action => 'new' }
      end
    end
  end

  #GET /admin/sale_volunteer_time/edit/:id
  def edit
    @sale_volunteer_sign_up = SaleVolunteerSignUp.find(params[:id])
    @sale_volunteer_time = @sale_volunteer_sign_up.sale_volunteer_time
    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  # PUT /admin/sale_volunteer_time/:id
  def update
    @sale_volunteer_sign_up = SaleVolunteerSignUp.find(params[:id])

    respond_to do |format|
      if @sale_volunteer_sign_up.update_attributes(params[:sale_volunteer_sign_up])
        flash[:notice] = 'Helper Sign Up was successfully updated.'
        format.html { redirect_to (session[:return_url]) }
      else
        @sale_volunteer_time = @sale_volunteer_sign_up.sale_volunteer_time
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /admin/sale_volunteer_sign_up/:id  
  def destroy
    @sale_volunteer_sign_up = SaleVolunteerSignUp.find(params[:id])
    @sale_volunteer_sign_up.destroy

    respond_to do |format|  
      flash[:warning] = "Helper removed from this time slot"
      format.html { redirect_to (session[:return_url]) }
    end
  end    
end
