class Admin::RewardsImportsController < ApplicationController
  require 'csv'

  def new
    @rewards_import = RewardsImport.new
    @rewards_import.sale = Sale.find(params[:sale_id])
    @rewards_import.rewards_date = @rewards_import.sale.start_date
    @site_asset = SiteAsset.new
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  #Get /admin/sale/:sale_id/rewards_imports
  def index
    @sale = Sale.find(params[:sale_id])
    @rewards_imports = @sale.rewards_imports
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  # POST /admin/sale/:sale_id/rewards_import/
  def create
    @rewards_import = RewardsImport.new(params[:rewards_import])

    RewardsImport.transaction do
      uploaded_file_name = File.basename(params[:site_asset][:asset].original_filename)
      respond_to do |format|
        @site_asset = SiteAsset.find_by_asset_file_name(uploaded_file_name)
        if @site_asset          
          #A duplicate was found that did not belong to this franchise
          conflicting_file_name = true
          flash[:warning] = "A duplicate site asset was found with the same name as your import.  Please re-name your import and re-upload.  If you need to re-upload your transactions, first delete your existing import file and try again."
          format.html { render :action => 'new' }
          bad_file = true
          format.html { render :action => 'new' }
        else
          @site_asset = SiteAsset.new(params[:site_asset])
        end
        @site_asset.display_name = "#{@rewards_import.sale.franchise.franchise_name}_#{uploaded_file_name}"
  
        #validate that this is a csv file
        unless conflicting_file_name || bad_file
          if uploaded_file_name[-4, 4] == ".csv"
            @site_asset.save!
            @rewards_import.site_asset_id = @site_asset.id
            @rewards_import.save!
            do_import
            format.html { redirect_to(admin_sale_rewards_imports_url(@rewards_import.sale)) }
          else
            flash[:error] = "You can only upload csv files for the import process."
            format.html { render :action => 'new' }
          end
        end
      end
    end
    
  rescue ActiveRecord::RecordInvalid => e
    flash[:error] = "There was an error in the import for ##{e.record.rewards_number}. #{e.record.errors.full_messages.join(", ")}"
    respond_to do |format|
      format.html { render :action => 'new' }
    end
  end

  # DELETE /admin/sale/:sale_id/rewards_import/:id
  def destroy
    @rewards_import = RewardsImport.find(params[:id])
    respond_to do |format|
      if @rewards_import.sale_id == params[:sale_id].to_i
        @site_asset = @rewards_import.site_asset
        @site_asset.destroy
        flash[:warning] = "Reward Import File was successfully deleted."
      else
        flash[:error] = "You are not authorized to delete that reward import"
      end
      format.html { redirect_to(admin_sale_rewards_imports_url(@rewards_import.sale)) }
    end
  end

  protected
    def do_import
      @rewards_import.sale_id
      import_file = File.open(@rewards_import.site_asset.file_path, "r") { |f| f.read }
      parsed_file = CSV::Reader.parse(import_file)
      parsed_file.each do |row|
        # read data
        @rewards_number = row[0].to_i
        @awards_applied = row[1].to_i
    
        unless @rewards_number == 0 || @awards_applied == 0
          #now find the reward profile being imported
          @rewards_profile = RewardsProfile.find(:first, :conditions => ["rewards_number = ?", @rewards_number])
          if @rewards_profile.nil? #Item doesn't exist, add a new one
            create_rewards
          end
          
          #create rewards earning
          @rewards_earning = RewardsEarning.new
          @rewards_earning.rewards_import_id = @rewards_import.id
          @rewards_earning.sale_id = @rewards_import.sale_id
          @rewards_earning.rewards_profile_id = @rewards_profile.id
          @rewards_earning.amount_applied = @awards_applied
          @rewards_earning.save!
        end
      end            
    end

    def create_rewards
      @rewards_profile = RewardsProfile.new
      @rewards_profile.rewards_number = @rewards_number
      @rewards_profile.rewards_number_confirmation = @rewards_number
      @rewards_profile.save!      
    end
end
