class Admin::FranchisesController < ApplicationController
  require 'csv'
  layout 'admin/kids_closet'
#  require 'fastercsv'
  before_filter :load_usa_provinces, :only => [:new, :create, :edit, :update]
  before_filter :load_saved_profile_search, :except => [:destroy, :consignors_history]
  before_filter :load_saved_profile_history_search, :only => [:consignors_history]
  before_filter :load_saved_rewards_search, :only => [:rewards_available, :rewards_list]
  before_filter :set_admin_status
  before_filter :require_owner_or_admin, :except => [:index, :new, :create, :import_data, :score_card_export]
  before_filter :require_any_owner_or_admin, :only => :score_card_export
  before_filter :require_admin, :only => [:new, :create, :import_data, :destroy]
  #GET /admin/franchises
  def index
    if @admin
      @franchises = Franchise.paginate(:all, :include => :province, :order => "franchise_name", :page => params[:page])
    else
      franchise_owner_profiles = current_profile.franchise_owner_profiles
      @franchises = Franchise.paginate(:all, :include => :province, :order => "franchise_name", :conditions => ["id in (?)", franchise_owner_profiles.empty? ? 0 : franchise_owner_profiles.map(&:franchise_id)], :page => params[:page])
    end
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  #GET /admin/franchises/new
  def new
    @franchise = Franchise.new
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /admin/franchises/
  def create
    @franchise = Franchise.new(params[:franchise])

    respond_to do |format|
      if @franchise.save
        flash[:notice] = 'Franchise was successfully created.'
        format.html { redirect_to :action => "index" }
      else
        format.html { render :action => "new" }
      end
    end
  end

  #GET /admin/franchises/edit/:id
  def edit
    @franchise = Franchise.find(params[:id])
    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  # PUT /admin/franchises/:id
  def update
    @franchise = Franchise.find(params[:id])

    respond_to do |format|
      if @franchise.update_attributes(params[:franchise])
        flash[:notice] = 'Franchise was successfully updated.'
        format.html { redirect_to :action => "index" }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # Put /admin/sales/:id/update_content
  def update_content
    @franchise = Franchise.find(params[:id])
    respond_to do |format|
      if @franchise.update_attributes(params[:franchise])
        flash[:notice] = 'Mini Content was successfully updated.'
        format.html { redirect_to(admin_franchise_url(@franchise)) }
      else
        @franchise_owners = @franchise.owners 
        @sales = @franchise.sales
        format.html { render :action => "show" }
      end
    end
  end

  def show
    @franchise = Franchise.find(params[:id]) 
    @franchise.load_content  
    @franchise_owners = @franchise.owners 
    @sales = @franchise.sales
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  #get /admin/franchies/:id/consignors
  def consignors
    @franchise = Franchise.find(params[:id])
    @franchise_profiles = @franchise.consignor_profiles.paginate(:include => :profile, :order => "profiles.last_name, profiles.first_name", :page => params[:page])
    @list_type = "Consignors"
    session[:return_url] = request.request_uri
    respond_to do |format|
      format.html {render :profile_list} # profile_list.html.erb
    end
  end
  
  #get /admin/franchies/:id/consignors_history
  def consignors_history
    @franchise = Franchise.find(params[:id])

    if params[:clear]
      clear_profile_history_search
    end
    if @franchise_profile_history_search.nil?
      create_new_profile_history_search
    end
    save_profile_history_search
    search_consignor_history_profiles
    session[:return_url] = request.request_uri

    respond_to do |format|
      format.html # consignors.html.erb
    end
  end

  #get /admin/franchies/:id/consignors_history_export
  def consignors_history_export
    franchise = Franchise.find(params[:id])
    Delayed::Job.enqueue(
      KidsCloset::ConsignorHistoryExport.new(params[:id], current_user.profile.email), 0, 2.seconds.from_now
    )
    flash[:notice] = "You will receive an email with a link to the export file shortly."
    
    respond_to do |format|
      format.html {redirect_to consignors_history_admin_franchise_url(franchise)}
    end
  end

  #get /admin/franchies/:id/volunteers
  def volunteers
    @franchise = Franchise.find(params[:id])
    @franchise_profiles = @franchise.volunteer_profiles.paginate(:include => :profile, :order => "profiles.last_name, profiles.first_name", :page => params[:page])
    @list_type = "Helpers"
    session[:return_url] = request.request_uri
    respond_to do |format|
      format.html {render :profile_list} # profile_list.html.erb
    end
  end

  #get /admin/franchies/:id/volunteers_history
  def volunteers_history
    @franchise = Franchise.find(params[:id])
    @franchise_profiles = @franchise.volunteer_profiles.paginate(:include => :profile, :order => "profiles.last_name, profiles.first_name", :page => params[:page])
    session[:return_url] = request.request_uri
    respond_to do |format|
      format.html # volunteers_history.html.erb
    end
  end

  #get /admin/franchies/:id/volunteers_history_export
  def volunteers_history_export
    franchise = Franchise.find(params[:id])
    franchise_profiles = franchise.volunteer_profiles
    csv_string = FasterCSV.generate do |csv|
      csv << ['#', 'Name', 'Email', 'Phone', 'Origination Date', 'Last Helping Date', '# Helper Slots this Sale', '# Lifetime Helper Slots', '# Lifetime Events']
      for franchise_profile in franchise_profiles
        csv << [franchise_profile.profile_id, franchise_profile.profile.full_name, franchise_profile.profile.email, franchise_profile.profile.phone.as_phone, franchise_profile.created_at.strftime("%B, %d, %Y"),franchise_profile.last_volunteer_date, franchise_profile.last_sale_volunteer_slots, franchise_profile.lifetime_volunteer_slots, franchise_profile.number_of_sales_volunteered]
      end
    end
    send_data csv_string,
            :type => 'text/csv; charset=iso-8859-1; header=present',
            :disposition => "attachment; filename=franchise_#{franchise.id}_volunteers_history_export.csv"
  end

  #get /admin/franchises/:id/mailing_list_members
  def mailing_list_members
    @franchise = Franchise.find(params[:id])
    @franchise_profiles = @franchise.mailing_list_member_profiles.paginate(:include => :profile, :order => "profiles.last_name, profiles.first_name", :page => params[:page])
    @list_type = "Mailing List Members"
    session[:return_url] = request.request_uri
    respond_to do |format|
      format.html {render :profile_list} # profile_list.html.erb
    end
  end

  def bad_email_list
    @franchise = Franchise.find(params[:id])
    @franchise_profiles = @franchise.bad_email_profiles.paginate(:page => params[:page])
    @list_type = "Members with Bad Emails List"
    session[:return_url] = request.request_uri
    respond_to do |format|
      format.html {render :profile_list} # profile_list.html.erb
    end
  end

  def profile_list
    @franchise = Franchise.find(params[:id])
    if params[:clear]
      clear_profile_search
    end
    if @franchise_profile_search.nil?
      create_new_profile_search
    end
    save_profile_search
    search_profiles

    @list_type = "Profiles"
    session[:return_url] = request.request_uri
    respond_to do |format|
      format.html # profile_list.html.erb
    end    
  end
  
  def found_us_report
    @franchise = Franchise.find(params[:id])
    @how_did_you_hears = HowDidYouHear.find :all
    @referred_consignors = @franchise.referred_consignors
    @other_reasons = @franchise.other_reasons
  end
  
  #get /admin/franchise/:id/import_members
  def import_members
    @franchise_profile = FranchiseProfile.new    
    @franchise = Franchise.find(params[:id])
    @franchise_profile.franchise = @franchise
    @site_asset = SiteAsset.new
    respond_to do |format|
      format.html # import_members.html.erb
    end    
  end

  #get /admin/franchise/:id/process_member_import
  def process_member_import
    @franchise_profile = FranchiseProfile.new(params[:franchise_profile])
    good_records = 0
    bad_records = 0
    uploaded_file_name = File.basename(params[:site_asset][:asset].original_filename)
    @site_asset = SiteAsset.find_by_asset_file_name(uploaded_file_name)
    if @site_asset          
      #A duplicate was found that did not belong to this franchise
      conflicting_file_name = true
      flash[:warning] = "Your import is currently processing or a duplicate site asset was found with the same name as your import file.  If you believe the import did not process simply change the name of the file and try again."
    else
      @site_asset = SiteAsset.new(params[:site_asset])
    end

    #validate that this is a csv file
    unless conflicting_file_name
      if uploaded_file_name[-4, 4] == ".csv" || uploaded_file_name[-4, 4] == ".txt"
        if @site_asset.save
          SiteAsset.transaction do
            @site_asset.save!
            import_file = File.open(@site_asset.file_path, "r") { |f| f.read }
            parsed_file = CSV::Reader.parse(import_file)
            imported_emails = []
            parsed_file.each do |row|
              # read data
              first_name = row[0]
              last_name = row[1]
              email = row[2]
              first_name = email if first_name.blank?
              last_name = "N/A" if last_name.blank?
              #now find if we have an existing profile
              unless imported_emails.include?(email)
                profile = Profile.find_by_email(email)
                profile ||= Profile.new
                profile.first_name = first_name
                profile.last_name = last_name
                profile.email = email
                profile.email_confirmation = email
                profile.phone = row[7].nil? ? "" : row[7]
                state = row[5]
                site_province = SiteProvince.find(:first, :include => :province, :conditions => ["provinces.name = ? OR code = ?", state, state.upcase]) unless row[5].nil?
                unless site_province.nil? || row[3].nil? || row[4].nil? || row[6].nil? || row[5].nil?
                  profile.address_site_province_id = site_province.id
                  profile.address_site_country_id = site_province.site_country_id
                  profile.address_address_line_1 = row[3]
                  profile.address_city = row[4]
                  profile.address_postal_code = row[6]
                end
                profile = update_profile_for_register_account(profile)
                if profile.save
                  franchise_profile = FranchiseProfile.find(:first, :conditions => ["profile_id = ? AND franchise_id = ?", profile.id, @franchise_profile.franchise_id])
                  franchise_profile ||= FranchiseProfile.new
                  send_email = !franchise_profile.mailing_list
                  franchise_profile.franchise_id = @franchise_profile.franchise_id
                  franchise_profile.profile_id = profile.id
                  franchise_profile.mailing_list = true if !@franchise_profile.consignor && !@franchise_profile.volunteer
                  franchise_profile.save
                  good_records += 1
                  imported_emails << profile.email
                  if send_email && franchise_profile.mailing_list
                    body_html = "<p>Thank you for signing up to receive emails from the Kid’s Closet Connection -  <b>#{@franchise_profile.franchise.franchise_name}</b> sale.</p><p>To ensure you receive future emails from Kid’s Closet Connection, please add this email address to your safe sender list.</p>"
                    subject = "Kids Closet Connection - Join Mailing List Confirmation"
                    email = KidsMailer.create_general_mass_email(franchise_profile.franchise, nil, profile, subject, body_html, "Remove me from this mailing list.", "http://www.kidscloset.biz/home/unsubscribe_franchise_profile/#{franchise_profile.id}", "donotreply@kidscloset.biz")	    			
                    if KidsMailer.deliver(email)
                      profile.histories.create(:message => "Mailing List Confirmation email sent")
                    end            
                  end
                else
                  bad_records += 1
                end
              end
            end            
            @site_asset.destroy
            if bad_records == 0
              flash[:notice] = "Import Successfully Processed. #{good_records} were imported successfuly"
            elsif good_records == 0
              flash[:error] = "No records were imported.  #{bad_records} were detected.  Please ensure you are following the right format in the file and that all records have a valid email address."
            else
              flash[:warning] = "Import Processed with Errors.  #{good_records} records were imported successfully.  #{bad_records} records failed.  Please make sure that all records have a valid email address and try to import those records again."
            end
          end
        else
          flash[:error] = "Could not upload the import file"
          @franchise = @franchise_profile.franchise
          respond_to do |format|      
            format.html { render :action => 'import_members' }
          end          
          return
        end
      else
        flash[:error] = "You can only upload .csv or .txt files for the import process."
      end
    end
    respond_to do |format|
      format.html { redirect_to(admin_franchise_url(@franchise_profile.franchise)) }
    end

  rescue ActiveRecord::RecordInvalid => e
    flash[:error] = "Could not upload the import file"
    @site_asset.destroy
    @franchise = @franchise_profile.franchise
    respond_to do |format|      
      format.html { render :action => 'import_members' }
    end
    
    
  end

  def export_members
    franchise = Franchise.find(params[:id])
    franchise_profiles = franchise.active_profiles
    csv_string = FasterCSV.generate do |csv|
      csv << ['Email', 'Consignor #', 'Sort Group', 'Address', 'City', 'State', 'Zip Code', 'First Name', 'Last Name', 'Phone']
      for profile in franchise_profiles
        address = profile.addresses.find(:first)
        if address.nil?
          csv << [profile.email, profile.id, profile.sort_column, '', '', '', '', profile.first_name, profile.last_name, profile.phone ]
        else
          csv << [profile.email, profile.id, profile.sort_column, address.address_line_1, address.city, address.site_province.province.code, address.postal_code, profile.first_name, profile.last_name, profile.phone ]
        end          
      end
    end
    send_data csv_string,
            :type => 'text/csv; charset=iso-8859-1; header=present',
            :disposition => "attachment; filename=franchise_#{franchise.id}_member_export.csv"    
  end

  def export_texting_profiles
    franchise = Franchise.find(params[:id])
    franchise_texting_profiles = franchise.franchise_texting_profiles
    csv_string = FasterCSV.generate do |csv|
      csv << ['Phone', 'Date Added']
      for profile in franchise_texting_profiles
        csv << [profile.phone, profile.created_at.strftime("%B, %d, %Y")]
      end
    end
    send_data csv_string,
            :type => 'text/csv; charset=iso-8859-1; header=present',
            :disposition => "attachment; filename=franchise_#{franchise.id}_texting_profiles_export.csv"    
  end

  def bad_email_export
    franchise = Franchise.find(params[:id])
    franchise_profiles = franchise.bad_email_profiles
    csv_string = FasterCSV.generate do |csv|
      csv << ['Consignor #', 'Address', 'City', 'State', 'Zip Code', 'First Name', 'Last Name', 'Phone']
      for franchise_profile in franchise_profiles
        address = franchise_profile.profile.addresses.find(:first)
        if address.nil?
          csv << [franchise_profile.profile.id, '', '', '', '', franchise_profile.profile.first_name, franchise_profile.profile.last_name, franchise_profile.profile.phone ]
        else
          csv << [franchise_profile.profile.id, address.address_line_1, address.city, address.site_province.province.code, address.postal_code, franchise_profile.profile.first_name, franchise_profile.profile.last_name, franchise_profile.profile.phone ]
        end          
      end
    end
    send_data csv_string,
            :type => 'text/csv; charset=iso-8859-1; header=present',
            :disposition => "attachment; filename=franchise_#{franchise.id}_member_export.csv"    
  end

  # DELETE /admin/franchises/:id
  def destroy
    @franchise = Franchise.find(params[:id])
    @franchise.destroy

    respond_to do |format|
      flash[:warning] = "Franchise was successfully deleted."
      format.html { redirect_to :action => "index" }
    end
  end
  
  def rewards_available
    @franchise = Franchise.find(params[:id])
    @previous_sales = @franchise.sales
  	@available_profiles = RewardsProfile.rewards_profiles.paginate(:page => params[:page], :per_page => 50)
    respond_to do |format|
      format.html # rewards_available.html.erb
    end    
  end

  def rewards_list
    @franchise = Franchise.find(params[:id])
    @previous_sales = @franchise.sales
    if params[:clear]
      clear_rewards_search
    end
    if @rewards_profile_search.nil?
      create_new_rewards_search
    end
    save_rewards_search
    search_rewards

    @list_type = "Reward Profiles"
    session[:return_url] = request.request_uri
    respond_to do |format|
      format.html { render :action => "rewards_available" }
    end    
  end  

  def rewards_export
    franchise = Franchise.find(params[:id])
    Delayed::Job.enqueue(
      KidsCloset::ClosetCashExport.new(params[:id], current_user.profile.email), 0, 2.seconds.from_now
    )
    flash[:notice] = "You will receive an email with a link to the export file shortly."
    
    respond_to do |format|
      format.html {redirect_to rewards_available_admin_franchise_url(franchise)}
    end
  end

  def score_card_export
    Delayed::Job.enqueue(
      KidsCloset::ScoreCardExport.new(@admin, current_profile_id, current_user.profile.email), 0, 2.seconds.from_now
    )
    flash[:notice] = "You will receive an email with a link to the export file shortly."
    
    respond_to do |format|
      format.html {redirect_to admin_franchises_url}
    end
  end

  private

    def load_usa_provinces
      @provinces = Province.find(:all, :conditions => ['country_id = ?', 1])
    end

    def set_admin_status
      @admin = !current_user.user_groups.find(:first, :conditions => ["name = ? OR name = ?", 'Administrators', 'Site Administrators']).nil?
    end    

    def require_owner_or_admin
      unless @admin || current_profile.franchise_owner_profiles.find(:first, :conditions => ["franchise_id = ?", params[:id]]).not_nil?
        flash[:error] = "Unauthorized"
        redirect_to "/"
      end
    end

    def require_any_owner_or_admin
      unless @admin || current_profile.franchise_owner_profiles.find(:first).not_nil?
        flash[:error] = "Unauthorized"
        redirect_to "/"
      end
    end

    def require_admin
      @admin
    end

    def update_profile_for_register_account(profile)
      profile.acquisition_source = "Franchise Owner Member Import"
      unless profile.address_postal_code.empty_or_nil?
        unless profile.new_record?
          address = profile.addresses.find(:first, :conditions => ["label = ?", "Main Address"])
          address.destroy unless address.nil?
        end
        profile.address_label = "Main Address"
        profile.address_first_name = profile.first_name
        profile.address_last_name = profile.last_name
        profile.addresses.build(
          :label => profile.address_label,
          :first_name => profile.address_first_name,
          :last_name => profile.address_last_name,
          :address_line_1 => profile.address_address_line_1,
          :address_line_2 => "",
          :city => profile.address_city,
          :site_country_id => profile.address_site_country_id,
          :site_province_id => profile.address_site_province_id,
          :postal_code => profile.address_postal_code
        )
      end
      profile.is_subscribed = true
      profile
    end
  
    def load_saved_profile_search
      if session[:franchise_profile_search].not_nil? && params[:franchise_profile_search].nil?
        @franchise_profile_search = session[:franchise_profile_search]
        if @franchise_profile_search.franchise_id != params[:id]
          @franchise_profile_search = FranchiseProfileSearch.new
          @franchise_profile_search.franchise_id = params[:id]
        end
      elsif params[:franchise_profile_search].nil?
        @franchise_profile_search = FranchiseProfileSearch.new
        @franchise_profile_search.franchise_id = params[:id]
      end
    end

    def clear_profile_search
      @franchise_profile_search = nil
      params[:franchise_profile_search] = nil
    end

    def create_new_profile_search
      @franchise_profile_search = FranchiseProfileSearch.new(new_profile_search_params)
      @franchise_profile_search.page = params[:page] || 1
      @franchise_profile_search.franchise_id = params[:id]
    end

    def new_profile_search_params
      params[:franchise_profile_search]
    end

    def save_profile_search
      session[:franchise_profile_search] = @franchise_profile_search
    end
  
    def search_profiles
      @franchise_profiles = @franchise_profile_search.profiles
    end

    def load_saved_profile_history_search
      if session[:franchise_profile_history_search].not_nil? && params[:franchise_profile_history_search].nil?
        @franchise_profile_history_search = session[:franchise_profile_history_search]
        if @franchise_profile_history_search.franchise_id != params[:id]
          @franchise_profile_history_search = FranchiseProfileSearch.new
          @franchise_profile_history_search.franchise_id = params[:id]
        end
      elsif params[:franchise_profile_history_search].nil?
        @franchise_profile_history_search = FranchiseProfileSearch.new
        @franchise_profile_history_search.franchise_id = params[:id]
      end
    end

    def clear_profile_history_search
      @franchise_profile_history_search = nil
      params[:franchise_profile_history_search] = nil
    end

    def create_new_profile_history_search
      @franchise_profile_history_search = FranchiseProfileSearch.new(new_profile_history_search_params)
      @franchise_profile_history_search.page = params[:page] || 1
      @franchise_profile_history_search.franchise_id = params[:id]
    end

    def new_profile_history_search_params
      params[:franchise_profile_history_search]
    end

    def save_profile_history_search
      session[:franchise_profile_history_search] = @franchise_profile_history_search
    end
  
    def search_consignor_history_profiles
      @franchise_profiles = @franchise_profile_history_search.profiles
    end

    def create_temp_profile(id)
      profile = Profile.new
      profile.id = id
      profile.email = "consignor#{id}@kidscloset.biz"
      profile.email_confirmation = "consignor#{id}@kidscloset.biz"
      profile.first_name = "Consignor"
      profile.last_name = id
      profile.phone = ""
      profile.save 
    end

    def load_saved_rewards_search
      if session[:rewards_profile_search].not_nil? && params[:rewards_profile_search].nil?
        @rewards_profile_search = session[:rewards_profile_search]
      elsif params[:rewards_profile_search].nil?
        @rewards_profile_search = RewardProfileSearch.new
        @rewards_profile_search.franchise_id = params[:id]
      end
    end

    def clear_rewards_search
      @rewards_profile_search = nil
      params[:rewards_profile_search] = nil
    end

    def create_new_rewards_search
      @rewards_profile_search = RewardProfileSearch.new(new_rewards_search_params)
      @rewards_profile_search.page = params[:page] || 1
      @rewards_profile_search.franchise_id = params[:id]
    end

    def new_rewards_search_params
      params[:rewards_profile_search]
    end

    def save_rewards_search
      session[:rewards_profile_search] = @rewards_profile_search
    end
  
    def search_rewards
      @available_profiles = @rewards_profile_search.profiles
    end

end
