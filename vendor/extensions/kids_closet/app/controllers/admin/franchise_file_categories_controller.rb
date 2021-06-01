class Admin::FranchiseFileCategoriesController < ApplicationController
  before_filter :set_admin_status
  before_filter :require_admin, :only => [:create, :edit, :update, :destroy, :mew]
  
  #Get /admin/franchise_category_files
  def index
    @franchise_file_category = FranchiseFileCategory.new
    @franchise_file_categories = FranchiseFileCategory.paginate(:all, :order => "title", :page => params[:page])
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def new
    
  end

  #GET /admin/franchise_file_categories/:id
  def show
    @franchise_file = FranchiseFile.new
    @franchise_file.franchise_file_category = FranchiseFileCategory.find(params[:id])
    @franchise_files = @franchise_file.franchise_file_category.franchise_files
    @site_asset = SiteAsset.new
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  #Post /admin/franchise_category_file
  def create  
    @franchise_file_category = FranchiseFileCategory.new(params[:franchise_file_category])
    respond_to do |format|
      if @franchise_file_category.save
        flash[:notice] = "File Category Created Successfully"
        format.html { redirect_to admin_franchise_file_categories_url}
      else
        format.html { render :action => "new"}
      end
    end
  end
  
  #Get /admin/franchise_category_file/:id
  def edit
    @franchise_file_category = FranchiseFileCategory.find(params[:id])
    respond_to do |format|
      format.html # edit.html.erb
    end
  end
  
  #PUT /admin/franchise_category_file/:id
  def update
    @franchise_file_category = FranchiseFileCategory.find(params[:id])

    respond_to do |format|
      if @franchise_file_category.update_attributes(params[:franchise_file_category])
        flash[:notice] = "File Category successfully updated"
        format.html { redirect_to admin_franchise_file_categories_url}
      else
        format.html { render :action => "edit"}
      end
    end
  end
  
  # DELETE /admin/franchise_category_file/:id
  def destroy
    @franchise_file_category = FranchiseFileCategory.find(params[:id])
    @franchise_file_category.destroy

    respond_to do |format|
      flash[:warning] = "File Category was successfully deleted."
        format.html { redirect_to admin_franchise_file_categories_url}
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
