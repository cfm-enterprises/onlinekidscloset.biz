class Admin::BusinessPartnersController < ApplicationController
  #GET /admin/sales/:sale_id/consignor_times
  def index
    @sale = Sale.find(params[:sale_id])
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  #GET /admin/sale/:sale_id/consignor_times/new/
  def new
    @sale = Sale.find(params[:sale_id])
    @business_partner =  BusinessPartner.new
    @business_partner.sale = @sale
    @business_partner.sort_index = @sale.next_available_business_partner_sort_index
    @site_asset = SiteAsset.new
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /admin/sale/:sale_id/consignor_time/
  def create
    @business_partner = BusinessPartner.new(params[:business_partner])
    uploaded_file_name = File.basename(params[:site_asset][:asset].original_filename)
    respond_to do |format|
      format.html { redirect_to(new_admin_sale_business_partner_url(@business_partner.sale)) }
      @site_asset = SiteAsset.find_by_asset_file_name(uploaded_file_name)
      @site_asset ||= @site_asset = SiteAsset.new(params[:site_asset])
      @site_asset.display_name = "logo_for_#{@business_partner.partner_title}}"
      if @site_asset.image_type?
        BusinessPartner.transaction do
          @site_asset.save!
          @business_partner.site_asset_id = @site_asset.id
          @business_partner.save!
          flash[:notice] = "Business Partner Successfully Added"
        end
      else
        flash[:error] = "You must select a valid photo file."
      end
    end
    
  rescue ActiveRecord::RecordInvalid => e
    @sale = @business_partner.sale
    flash[:error] = "Could not add the business partner"
    respond_to do |format|
      format.html { render :action => "new" }
    end
    
  end
  
  #GET /admin/sale/:sale_id/consignor_time/edit/:id
  def edit
    @business_partner = BusinessPartner.find(params[:id])
    @site_asset = @business_partner.site_asset
    @sale = @business_partner.sale
    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  # PUT /admin/sale/:sale_id/consignor_time/:id
  def update
    @business_partner = BusinessPartner.find(params[:id])

    respond_to do |format|
      if @business_partner.update_attributes(params[:business_partner])
        flash[:notice] = 'Business Partner was successfully updated.'
        format.html { redirect_to(admin_sale_business_partners_url(@sale)) }
      else
        @sale = @business_partner.sale
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /admin/consignor_times/:id
  def destroy
    @business_partner = BusinessPartner.find(params[:id])
    @business_partner.destroy
    
    respond_to do |format|
      flash[:warning] = "Business Partner was successfully deleted."
      format.html { redirect_to(admin_sale_business_partners_url(@business_partner.sale)) }
    end
  end  
end
