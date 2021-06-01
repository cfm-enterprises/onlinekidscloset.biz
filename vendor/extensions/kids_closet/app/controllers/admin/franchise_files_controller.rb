class Admin::FranchiseFilesController < ApplicationController
  before_filter :set_admin_status
  before_filter :require_admin

  def new
    
  end

  # POST /admin/franchise_category_file/:file_category_id/franchise_file/
  def create
    @franchise_file = FranchiseFile.new(params[:franchise_file])

    FranchiseFile.transaction do
      uploaded_file_name = File.basename(params[:site_asset][:asset].original_filename)
      respond_to do |format|
        format.html { redirect_to(admin_franchise_file_category_url(@franchise_file.franchise_file_category)) }
        @site_asset = SiteAsset.find_by_asset_file_name(uploaded_file_name)
        if @site_asset          
          #A duplicate was found, update attributes
          @site_asset.attributes = params[:site_asset]
        else
          @site_asset = SiteAsset.new(params[:site_asset])
        end
  
        @site_asset.save!
        @franchise_file.site_asset_id = @site_asset.id
        @franchise_file.save!
        flash[:notice] = "Franchise File successfully Uploaded."
      end
    end
    
  rescue ActiveRecord::RecordInvalid => e
    respond_to do |format|
      format.html { render :new }
    end
  end

  # DELETE /admin/franchise_file_category/:franchise_file_category_id/franchise_file
  def destroy
    @franchise_file = FranchiseFile.find(params[:id])
    respond_to do |format|
      @site_asset = @franchise_file.site_asset
      @site_asset.destroy
      flash[:warning] = "Franchise File was successfully deleted."
      format.html { redirect_to(admin_franchise_file_category_url(@franchise_file.franchise_file_category)) }
    end
  end

  protected
    def set_admin_status
      @admin = !current_user.user_groups.find(:first, :conditions => ["name = ? OR name = ?", 'Administrators', 'Site Administrators']).nil?
    end    

    def require_admin
      unless @admin
        flash[:error] = "Unauthorized"
        respond_to do |format|
          format.html redirect_to admin_url
        end
      end
    end
end
