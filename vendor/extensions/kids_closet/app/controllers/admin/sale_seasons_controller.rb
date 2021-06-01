class Admin::SaleSeasonsController < ApplicationController
  before_filter :set_admin_status
  before_filter :require_admin
  
  #Get /admin/sale_seasons
  def index
    @sale_season = SaleSeason.new
    @sale_seasons = SaleSeason.find(:all, :order => "start_date DESC")
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def new
    @sale_season = SaleSeason.new
    last_sale_season = SaleSeason.latest_sale_season
    unless last_sale_season.nil?
      @sale_season.start_date = last_sale_season.end_date + 1
      @sale_season.end_date = (@sale_season.start_date >> 6) - 1
    end
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  #GET /admin/sale_seasons/:id
  def show
    @sale_season = SaleSeason.find(params[:id])
    @sales = @sale_season.sales
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  #GET /admin/sale_seasons/:id/reports
  def reports
    @sale_season = SaleSeason.find(params[:id])
    @sale_reports = @sale_season.sales
    respond_to do |format|
      format.html # show.html.erb
    end
  end
  
  #POST /admin/sale_seasons/:id/archive
  def archive
    Delayed::Job.enqueue(
      KidsCloset::ArchiveSeason.new(params[:id]), 0, 30.seconds.from_now
    )
    respond_to do |format|
      flash[:notice] = "Sale Season Archive Scheduled Successfully"
      format.html { redirect_to admin_sale_seasons_url}  
    end
  end

  #Post /admin/sale_season
  def create  
    @sale_season = SaleSeason.new(params[:sale_season])
    respond_to do |format|
      if @sale_season.save
        flash[:notice] = "Sale Season Created Successfully"
        format.html { redirect_to admin_sale_seasons_url}
      else
        format.html { render :action => "new"}
      end
    end
  end
  
  #Get /admin/sale_season/:id
  def edit
    @sale_season = SaleSeason.find(params[:id])
    respond_to do |format|
      format.html # edit.html.erb
    end
  end
  
  #PUT /admin/sale_season/:id
  def update
    @sale_season = SaleSeason.find(params[:id])

    respond_to do |format|
      if @sale_season.update_attributes(params[:sale_season])
        flash[:notice] = "Sale Season successfully updated"
        format.html { redirect_to admin_sale_seasons_url}
      else
        format.html { render :action => "edit"}
      end
    end
  end
  
  # DELETE /admin/sale_season/:id
  def destroy
    @sale_season = SaleSeason.find(params[:id])
    @sale_season.destroy

    respond_to do |format|
      flash[:warning] = "Sale Season was successfully deleted."
      format.html { redirect_to admin_sale_seasons_url}
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
