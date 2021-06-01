class Admin::SaleConsignorSignUpsController < ApplicationController


  def new
    respond_to do |format|
      format.html # new.html.erb
    end    
  end
  
  # post /admin/sale_consignor_time
  def create
    @sale_consignor_sign_up = SaleConsignorSignUp.new(params[:sale_consignor_sign_up])
    
    respond_to do |format|
      if @sale_consignor_sign_up.save
        flash[:notice] = 'Consignor Assigned to this time.'
        format.html { redirect_to (session[:return_url]) }
      else
        @sale_consignor_time = @sale_consignor_sign_up.sale_consignor_time
        @available_consignors = SaleConsignorSignUp.load_available_consignors(@sale_consignor_time)
        format.html { render :action => 'new' }
      end
    end
  end

  #GET /admin/sale_consignor_time/edit/:id
  def edit
    @sale_consignor_sign_up = SaleConsignorSignUp.find(params[:id])
    @sale_consignor_time = @sale_consignor_sign_up.sale_consignor_time
    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  # PUT /admin/sale_consignor_time/:id
  def update
    @sale_consignor_sign_up = SaleConsignorSignUp.find(params[:id])

    respond_to do |format|
      if @sale_consignor_sign_up.update_attributes(params[:sale_consignor_sign_up])
        flash[:notice] = 'Consignor Sign Up was successfully updated.'
        if session[:return_url]
          format.html {redirect_to (session[:return_url])}
        else
          format.html { redirect_to (consignors_admin_sale_url(@sale_consignor_sign_up.sale_consignor_time.sale)) }
        end
      else
        @sale_consignor_time = @sale_consignor_sign_up.sale_consignor_time
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /admin/sale_consignor_sign_up/:id  
  def destroy
    @sale_consignor_sign_up = SaleConsignorSignUp.find(params[:id])
    if @sale_consignor_sign_up.sale_consignor_time.internal
      @sale_consignor_sign_up.destroy
    else
      @sale_consignor_sign_up.sale_consignor_time_id = SaleConsignorTime.internal_time_for_sale(@sale_consignor_sign_up.sale_consignor_time.sale_id)
      @sale_consignor_sign_up.save
    end

    respond_to do |format|  
      flash[:warning] = "Consignor removed from this time slot"
      format.html { redirect_to (session[:return_url]) }
    end
  end    
  
  # GET /admin/sale_consignor_sign_up/:id/consignor_contract
  def consignor_contract
    @sale_consignor_sign_up = SaleConsignorSignUp.find(params[:id])
    render :layout => false
  end

  def update_sale_percentage
    @sale_consignor_sign_up = SaleConsignorSignUp.find(params[:id])
    @sale_consignor_sign_up.sale_percentage = params[:new_sale_percentage]
    if @sale_consignor_sign_up.save
      @row_color = "green"
    else
      @row_color = "error"
    end
    render :layout => false
  end
end
