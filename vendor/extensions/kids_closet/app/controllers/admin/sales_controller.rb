class Admin::SalesController < ApplicationController
  #GET /admin/franchise/:franchise_id/sales/new/
  before_filter :load_saved_rewards_search, :only => [:rewards_manager, :rewards_list]
  before_filter :load_saved_signed_up_consignor_search, :only => [:consignors, :consignors_report, :consignors_and_volunteers_export]
  before_filter :load_saved_signed_up_consignor_history_search, :only => [:consignors_history]
  before_filter :set_admin_status, :only => [:new, :edit, :create, :update]
  before_filter :set_super_admin_status, :only => [:new, :edit, :create, :update]

  def new
    @sale = Sale.new
    @sale.franchise_id = params[:franchise_id]
    last_sale = Sale.latest_sale_for_franchise(params[:franchise_id])
    unless last_sale.nil?
      @sale.sale_address = last_sale.sale_address
      @sale.sale_address2 = last_sale.sale_address2
      @sale.sale_zip_code = last_sale.sale_zip_code
      @sale.sale_percentage = last_sale.sale_percentage
      @sale.sale_advert_cost = last_sale.sale_advert_cost
    end      
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /admin/franchise/:franchise_id/sale/
  def create
    @sale = Sale.new(params[:sale])

    respond_to do |format|
      if @sale.save
        flash[:notice] = 'Franchise Sale was successfully created.'
        format.html { redirect_to(admin_franchise_url(@sale.franchise)) }
      else
        @sale_seasons = SaleSeason.find(:all, :order => "id DESC") if @admin
        format.html { render :action => "new" }
      end
    end
  end
  
  #GET /admin/franchises/:id/edit/:id
  def edit
    @sale = Sale.find(params[:id])
    @sale_seasons = SaleSeason.find(:all, :order => "id DESC") if @admin
    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  # PUT /admin/franchises/:id/sale
  def update
    @sale = Sale.find(params[:id])

    respond_to do |format|
      if @sale.update_attributes(params[:sale])
        flash[:notice] = 'Franchise Sale was successfully updated.'
        format.html { redirect_to(admin_franchise_url(@sale.franchise)) }
      else
        @sale_seasons = SaleSeason.find(:all, :order => "id DESC") if @admin
        format.html { render :action => "edit" }
      end
    end
  end

  # Put /admin/sales/:id/upload_pdf
  def upload_pdf
    @sale = Sale.find(params[:id])
    uploaded_file_name = File.basename(params[:sale][:asset].original_filename)
    respond_to do |format|
      @site_asset = SiteAsset.find_by_asset_file_name(uploaded_file_name)
      if @site_asset
        
        #We have a duplicate file name...verify that the file name being replaced belongs to this franchise
        conflicting_sales_using_asset = !Sale.find(:first, :conditions => ["site_asset_id = ? AND franchise_id != ?", @site_asset.id, @sale.franchise_id]).nil?
        if conflicting_sales_using_asset
          
          #A duplicate was found that did not belong to this franchise
          flash[:warning] = "A duplicate site asset was found with the same name as your pdf file.  Please re-name your file and re-upload."
          format.html { redirect_to(admin_sale_url(@sale)) }
          return
        end
      else
        @site_asset = SiteAsset.new(params[:sale])
      end
      @site_asset.display_name = "sale_#{uploaded_file_name}"


      #validate that this is a pdf file
      if uploaded_file_name[-4, 4] == ".pdf"
        Sale.transaction do
          @site_asset.save!
          @sale.site_asset_id = @site_asset.id
          @sale.save!
          flash[:notice] = "Sale PDF File successfully Uploaded."
          format.html { redirect_to(admin_sale_url(@sale)) }
        end
      else
        flash[:error] = "You must select a pdf file."
        format.html { redirect_to(admin_sale_url(@sale)) }
      end
    end
    
  rescue ActiveRecord::RecordInvalid => e
    flash[:error] = "Could not upload pdf file"
    respond_to do |format|
      format.html { redirect_to(admin_sale_url(@sale)) }
    end
  end
  
  def show
    @sale = Sale.find(params[:id])   
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # Post /admin/sales/:id/make_active
  def make_active
    @sale = Sale.find(params[:id])
    @sale.active = true
    respond_to do |format|
      if @sale.save
        flash[:notice] = 'Sale Successfully Activated'
      else
        flash[:error] = 'Sale Could Not be Activated'
      end
      format.html { redirect_to(admin_franchise_url(@sale.franchise)) }
    end
  end

  def calculate_financials
    Delayed::Job.enqueue(
      KidsCloset::CalculateSaleFinancials.new(params[:id]), 0, 10.seconds.from_now
    )
    respond_to do |format|
      flash[:notice] = 'Sale Financials recalculation in progress.'
      format.html { redirect_to(reports_admin_sale_url(@sale))}
    end
  end
  
  def deactivate_sale
    @sale = Sale.find(params[:id])
    respond_to do |format|
      @sale.active = false
      if @sale.save
        flash[:notice] = 'Sale Successfully De-Activated'
      else
        flash[:error] = 'Sale Could Not be De-Activated'
      end
      format.html { redirect_to(admin_franchise_url(@sale.franchise)) }
    end    
  end
  
  #get /admin/franchies/:id/consignors
  def consignors
    @sale = Sale.find(params[:id])

    if params[:clear]
      clear_signed_up_consignor_search
    end
    if @signed_up_consignor_search.nil?
      create_new_signed_up_consignor_search
    end
    save_signed_up_consignor_search
    search_profiles

    session[:return_url] = request.request_uri

    respond_to do |format|
      format.html # consignors.html.erb
    end
  end

  #get /admin/franchies/:id/consignors_export
  def consignors_and_volunteers_export
    print_profiles

    csv_string = FasterCSV.generate do |csv|
      csv << ['Consignor #', 'Total Active Inventory', 'Name', 'Email', 'Phone', 'Promo Code', 'Drop Off Day/Time', 'Job Title if Helping', 'Date/Time Helping']
      for consignor in @consignors
        volunteer_time = consignor.franchise_profile.sale_volunteer_sign_ups.find(:first, :include => :sale_volunteer_time, :conditions => ["sale_volunteer_times.sale_id = ?", params[:id]])
        csv << [consignor.franchise_profile.profile_id, consignor.franchise_profile.profile.items_coming, consignor.franchise_profile.profile.full_name, consignor.franchise_profile.profile.email, consignor.franchise_profile.profile.phone, consignor.promo_code, consignor.sale_consignor_time.internal ? "None Selected" : "#{consignor.sale_consignor_time.date.strftime("%b %d, %Y")} #{consignor.sale_consignor_time.start_time.strftime("%I:%M %p")}", volunteer_time.nil? ? "" : volunteer_time.sale_volunteer_time.job_title, volunteer_time.nil? ? "" : "#{volunteer_time.sale_volunteer_time.date.strftime("%b %d, %Y")} #{volunteer_time.sale_volunteer_time.start_time.strftime("%I:%M %p")}" ]
      end
    end

    send_data csv_string,
            :type => 'text/csv; charset=iso-8859-1; header=present',
            :disposition => "attachment; filename=sale_#{params[:id]}_consignor_and_volunteer_times_export.csv"
  end

  #get /admin/sales/:id/print_sort_labels
  def print_sort_labels
    sale = Sale.find(params[:id])
    @consignors = sale.consignor_profiles.find(:all, :conditions => ["quantity_sold > ?", 0], :order => "profiles.sort_column, profiles.id")
    respond_to do |format|
      format.html {render :layout => 'labels', :action => 'print_sort_labels'}# print_sort_labels.html.erb
      format.pdf {render  :template => 'customer/print_sort_labels.pdf.erb',
                          :pdf => "consignor_labels.pdf",
                          :layout => 'labels.html',
                          :page_size => 'Letter',
                          :margin => {
                            :top                => 0,
                            :bottom             => 0,
                            :left               => 0,
                            :right              => 0}                            
                  }         
    end
  end

  #get /admin/sales/:id/pick_up_report
  def pick_up_report
    @sale = Sale.find(params[:id])
    render :layout => false
  end

  #get /admin/franchies/:id/consignors
  def consignors_history
    @sale = Sale.find(params[:id])

    if params[:clear]
      clear_signed_up_consignor_history_search
    end
    if @signed_up_consignor_history_search.nil?
      create_new_signed_up_consignor_history_search
    end
    save_signed_up_consignor_history_search
    search_consignor_history_profiles
    session[:return_url] = request.request_uri

    respond_to do |format|
      format.html # consignors.html.erb
    end
  end
  
  #get /admin/sales/:id/consignors_history_export
  def consignors_history_export
    sale = Sale.find(params[:id])
    Delayed::Job.enqueue(
      KidsCloset::SaleConsignorHistoryExport.new(params[:id], current_user.profile.email), 0, 2.seconds.from_now
    )
    flash[:notice] = "You will receive an email with a link to the export file shortly."
    
    respond_to do |format|
      format.html {redirect_to consignors_history_admin_sale_url(sale)}
    end

  end

  #get /admin/sales/:id/volunteers
  def volunteers
    @sale = Sale.find(params[:id])
    @volunteers = @sale.volunteer_profiles.paginate(:page => params[:page])
    session[:return_url] = request.request_uri
    respond_to do |format|
      format.html # volunteers.html.erb
    end
  end

  def print_volunteers
    @sale = Sale.find(params[:id])
    @volunteers = @sale.volunteer_profiles
    render :layout => false
  end

  #get /admin/sale/:id/volunteers_history
  def volunteers_history
    @sale = Sale.find(params[:id])
    @volunteers = @sale.unique_volunteers.paginate(:page => params[:page])
      session[:return_url] = request.request_uri
    respond_to do |format|
      format.html # volunteers_history.html.erb
    end
  end

  #get /admin/sale/:id/volunteers_history_export
  def volunteers_history_export
    sale = Sale.find(params[:id])
    volunteers = sale.unique_volunteers
    csv_string = FasterCSV.generate do |csv|
      csv << ['#', 'Name', 'Email', 'Phone', 'Origination Date', 'Last Helping Date', '# Helper Slots this Sale', '# Lifetime Helper Slots', '# Lifetime Events']
      for volunteer in volunteers
        csv << [volunteer.profile_id, volunteer.profile.full_name, volunteer.profile.email, volunteer.profile.phone.as_phone, volunteer.created_at.strftime("%B, %d, %Y"),volunteer.last_volunteer_date, volunteer.last_sale_volunteer_slots(params[:id]), volunteer.lifetime_volunteer_slots, volunteer.number_of_sales_volunteered]
      end
    end
    send_data csv_string,
            :type => 'text/csv; charset=iso-8859-1; header=present',
            :disposition => "attachment; filename=sale_#{sale.id}_volunteers_history_export.csv"
  end

  def make_all_jobs_active
    sale = Sale.find(params[:id])
    for job in sale.draft_volunteer_jobs
      job.draft_status = false
      job.save
    end
    flash[:notice] = "All jobs are now active"
    respond_to do |format|
      format.html {redirect_to admin_sale_sale_volunteer_times_url(sale)}
    end
  end

  def rewards_manager
    @reward_profiles = RewardsProfile.rewards_profiles.paginate(:page => params[:page])
    session[:return_url] = request.request_uri
    respond_to do |format|
      format.html # rewards_manager.html.erb
    end
  end

  def rewards_list
    if params[:clear]
      clear_rewards_search
    end
    if @rewards_signed_up_consignor_search.nil?
      create_new_rewards_search
    end
    save_rewards_search
    search_rewards

    session[:return_url] = request.request_uri
    respond_to do |format|
      format.html { render :action => "rewards_manager" }
    end    
  end  

  def apply_reward
    @rewards_earning = RewardsEarning.new
    @rewards_earning.rewards_profile_id = params[:rewards_profile_id]
    @rewards_earning.sale_id = params[:id]
    @rewards_earning.amount_applied = params[:amount_earned]
    respond_to do |format|
      if @rewards_earning.save
        flash[:notice] = "Rewards applied to selected rewards member."
        format.html {redirect_to (session[:return_url])}
      else
        @sale = Sale.find(params[:id])
    		@reward_profiles = RewardsProfile.rewards_profiles.paginate(:page => params[:page])
        format.html { render :action => 'rewards_manager'}
      end
    end
  end

  def rewards_history
    @sale = Sale.find(params[:id])
    @rewards_earnings = @sale.rewards_earnings
    @total_applied = @rewards_earnings.sum(:amount_applied)
    respond_to do |format|
      format.html # rewards_history.html.erb
    end
  end

  def remove_reward
    rewards_profile_id = RewardsProfile.current_primary_card(params[:profile_id]).id
    @rewards_earning = RewardsEarning.find(:last, :conditions => ["rewards_profile_id = ? AND sale_id = ?", rewards_profile_id, params[:id]])
    @rewards_earning.destroy

    respond_to do |format|
      flash[:warning] = "Rewards Earning was successfully deleted."
      format.html { redirect_to(rewards_manager_admin_sale_url(@rewards_earning.sale)) }
    end    
  end

  #Get /admin/sale/:sale_id/reports
  def reports
    @sale = Sale.find(params[:id])
    respond_to do |format|
      format.html #reports.html.erb
    end
  end
  
  def financial_report
    @sale = Sale.find(params[:id])
    @consignors = @sale.consignor_profiles
    render :layout => false
  end

  def consignors_report
    @sale = Sale.find(params[:id])
    print_profiles
    render :layout => false
  end

  def volunteers_report
    @sale = Sale.find(params[:id])
    @volunteers = @sale.unique_volunteers
    render :layout => false
  end
  
  def check_report
    @sale = Sale.find(params[:id])
    @consignors = @sale.consignor_profiles.find(:all, :order => "profiles.id")
    render :layout => false
  end

  def online_sales_report
    @sale = Sale.find(params[:id])
    @orders = @sale.orders.paginate(:page => params[:page], :conditions => ["purchased_at IS NOT NULL"])
  end

  def buyer_item_reports
    @sale = Sale.find(params[:id])
    @buyers = @sale.buyers.uniq
    respond_to do |format|
      format.html {render  :template => 'admin/sales/buyer_item_reports.pdf.erb',
                        :pdf => "kcc_buyer_report.pdf",
                        :layout => 'tags.html',
                        :page_size => 'Letter',
                        :margin => {
                          :top                => 5,
                          :bottom             => 0,
                          :left               => 15,
                          :right              => 25}                            
                  }               
    end
  end

  def print_online_sales_report
    @sale = Sale.find(params[:id])
    @orders = @sale.orders
    render :layout => false
  end

  #get /admin/sales/:id/expired_pay_pal_orders
  def expired_pay_pal_orders
    @sale = Sale.find(params[:id])
    @pay_pal_orders = @sale.expired_pay_pal_orders.paginate(:page => params[:page])

    respond_to do |format|
      format.html # expired_pay_pal_orders.html.erb
    end
  end


  def export
  
  end

  def sales_export
    sale = Sale.find(params[:id])
    items_sold = sale.items_sold
    csv_string = FasterCSV.generate do |csv|
      csv << ['INVENTORY ID #', 'Consignor #', 'Description', 'Size', 'Featured', 'Original Price', 'Discount', 'Sold For', 'Sale Type']
      for item in items_sold
        csv << [item.id, item.profile_id, item.item_description, item.size, item.featured_item ? "Yes" : "No", "$#{item.price}", item.discounted_at_sale ? "50%" : "0%", sprintf( "$%.02f" , item.sale_price ), item.sold_online ? 'Online' : 'In Person']
      end
    end
    send_data csv_string,
            :type => 'text/csv; charset=iso-8859-1; header=present',
            :disposition => "attachment; filename=#{sale.franchise_id}_#{sale.id}_sales.csv"    
  end

  def online_sales_export
    sale = Sale.find(params[:id])
    items_sold = sale.orders
    csv_string = FasterCSV.generate do |csv|
      csv << ['Buyer First Name', 'Buyer Last Name', 'Buyer Email', 'Phone', 'Sort Code', 'Item #', 'Item Name', 'Size', 'Additional Information', 'Price', 'Sales Tax', 'Total', 'Consignor #', 'Consignor Name', 'Consignor Email', 'Consignor Phone']
      for item in items_sold
        csv << [item.buyer.first_name, item.buyer.last_name, item.buyer.email, item.buyer.phone.as_phone, item.seller.sort_column, item.consignor_inventory_id, item.item_name, item.consignor_inventory.nil? ? 'N/A after archive' : item.consignor_inventory.size, item.consignor_inventory.nil? ? 'N/A after archive' : item.consignor_inventory.additional_information, "$#{item.item_price}", "$#{item.sales_tax}", "$#{item.total_amount}", item.seller_id, item.seller.full_name, item.seller.email, item.seller.phone.as_phone ]
      end
    end
    send_data csv_string,
            :type => 'text/csv; charset=iso-8859-1; header=present',
            :disposition => "attachment; filename=#{sale.franchise_id}_#{sale.id}_online_sales.csv"    
  end


  def checks_export
    sale = Sale.find(params[:id])
    consignors = sale.consignor_profiles
    csv_string = FasterCSV.generate do |csv|
      csv << ['Consignor #', 'Name', 'Email', 'Address', 'City', 'State', 'Zip Code', 'Total Sales', 'Percentage', 'Ad Fee', 'Additional Proceeds', 'Net Proceeds']
      for consignor in consignors
        address = consignor.franchise_profile.profile.addresses.find(:first)
        address_line = address.nil? ? "" : "#{address.address_line_1}#{'; ' if address.address_line_2.not_blank?}#{address.address_line_2 if address.address_line_2.not_blank?}"
        city = address.nil? ? "" : address.city
        province = address.nil? ? "" : address.site_province.province.code
        postal_code = address.nil? ? "" : address.postal_code        
        csv << [consignor.franchise_profile.profile_id, consignor.franchise_profile.profile.name, consignor.franchise_profile.profile.email, address_line, city, province, postal_code, sprintf( "$%.02f" , consignor.total_sold), "#{consignor.sale_percentage}%", sprintf( "$%.02f" , consignor.advertisement_fee_paid), sprintf( "$%.02f" , (consignor.fee_adjustment)), sprintf( "$%.02f" , (consignor.check_amount))]
      end
    end
    send_data csv_string,
            :type => 'text/csv; charset=iso-8859-1; header=present',
            :disposition => "attachment; filename=#{sale.franchise_id}_#{sale.id}_checks.csv"    
  end

  def consignors_export
    sale = Sale.find(params[:id])
    consignors = sale.consignor_profiles.find(:all, :order => "profile_id")
    csv_string = FasterCSV.generate do |csv|
      csv << ['Consignor #', 'First Name', 'Last Name']
      for consignor in consignors
        csv << [consignor.franchise_profile.profile_id, consignor.franchise_profile.profile.first_name, consignor.franchise_profile.profile.last_name]
      end
    end
    send_data csv_string,
            :type => 'text/csv; charset=iso-8859-1; header=present',
            :disposition => "attachment; filename=#{sale.franchise_id}_#{sale.id}_signed_up_consignors.csv"    
  end

  def print_all_consignor_lists
    sale = Sale.find(params[:id])
    @sale_consignor_times = sale.sale_consignor_times
    render :layout => false
  end

  def print_drop_off_times
    @sale = Sale.find(params[:id])
    @sale_consignor_times = @sale.sale_consignor_times
    consignor_internal_time = @sale.sale_consignor_times.find(:first, :conditions => ["internal = ?", true])
    @internal_consignor_count = consignor_internal_time.consignor_profiles.count(:id)
    render :layout => false
  end

  def print_all_volunteer_lists
    sale = Sale.find(params[:id])
    @sale_volunteer_times = sale.sale_volunteer_times
    render :layout => false
  end

  def print_volunteer_jobs
    @sale = Sale.find(params[:id])
    @sale_volunteer_times = @sale.sale_volunteer_times
    render :layout => false
  end

  def promo_codes
    @sale = Sale.find(params[:id])
    @promo_codes = @sale.promo_codes_for_sale
    respond_to do |format|
      format.html # promo_codes.html.erb
    end
  end

  def promo_code_report
    @sale = Sale.find(params[:id])
    @promo_code = params[:promo_code]
    @consignors = @sale.consignor_profiles.find(:all, :conditions => ["sale_consignor_sign_ups.promo_code = ?", @promo_code])
    respond_to do |format|
      format.html # promo_code_report.html.erb
    end
  end

  private
    def set_admin_status
      @admin = !current_user.user_groups.find(:first, :conditions => ["name = ? OR name = ?", 'Administrators', 'Site Administrators']).nil?
    end    

    def set_super_admin_status
      @super_admin = current_user.site.nil? || !current_user.user_groups.find(:first, :conditions => ["name = ?", 'Site Administrators']).nil?
    end    

    def load_saved_rewards_search
      @sale = Sale.find(params[:id])
      if session[:rewards_signed_up_consignor_search].not_nil? && params[:rewards_signed_up_consignor_search].nil?
        @rewards_signed_up_consignor_search = session[:rewards_signed_up_consignor_search]
      elsif params[:rewards_signed_up_consignor_search].nil?
        @rewards_signed_up_consignor_search = RewardProfileSearch.new
        @rewards_signed_up_consignor_search.franchise_id = @sale.franchise_id
      end
    end

    def clear_rewards_search
      @rewards_signed_up_consignor_search = nil
      params[:rewards_signed_up_consignor_search] = nil
    end

    def create_new_rewards_search
      @rewards_signed_up_consignor_search = RewardProfileSearch.new(new_rewards_search_params)
      @rewards_signed_up_consignor_search.page = params[:page] || 1
      @rewards_signed_up_consignor_search.franchise_id = @sale.franchise_id
    end

    def new_rewards_search_params
      params[:rewards_signed_up_consignor_search]
    end

    def save_rewards_search
      session[:rewards_signed_up_consignor_search] = @rewards_signed_up_consignor_search
    end
  
    def search_rewards
      @reward_profiles = @rewards_signed_up_consignor_search.profiles
    end

    def load_saved_signed_up_consignor_search
      if session[:signed_up_consignor_search].not_nil? && params[:signed_up_consignor_search].nil?
        @signed_up_consignor_search = session[:signed_up_consignor_search]
        if @signed_up_consignor_search.sale_id != params[:id].to_i
          @signed_up_consignor_search = SignedUpConsignorSearch.new
          @signed_up_consignor_search.sale_id = params[:id]
          @signed_up_consignor_search.sort_order = ""
        else
          @signed_up_consignor_search.page = params[:page] || 1
        end
      elsif params[:signed_up_consignor_search].nil?
        @signed_up_consignor_search = SignedUpConsignorSearch.new
        @signed_up_consignor_search.sale_id = params[:id]
        @signed_up_consignor_search.sort_order = ""
      end
    end

    def clear_signed_up_consignor_search
      @signed_up_consignor_search = nil
      params[:signed_up_consignor_search] = nil
    end

    def create_new_signed_up_consignor_search
      @signed_up_consignor_search = SignedUpConsignorSearch.new(new_signed_up_consignor_search_params)
      @signed_up_consignor_search.page = params[:page] || 1
      @signed_up_consignor_search.sale_id = params[:id]
    end

    def new_signed_up_consignor_search_params
      params[:signed_up_consignor_search]
    end

    def save_signed_up_consignor_search
      session[:signed_up_consignor_search] = @signed_up_consignor_search
    end
  
    def search_profiles
      @consignors = @signed_up_consignor_search.profiles
    end

    def print_profiles
      @consignors = @signed_up_consignor_search.print_profiles
    end

    def load_saved_signed_up_consignor_history_search
      if session[:signed_up_consignor_history_search].not_nil? && params[:signed_up_consignor_history_search].nil?
        @signed_up_consignor_history_search = session[:signed_up_consignor_history_search]
        if @signed_up_consignor_history_search.sale_id != params[:id].to_i
          @signed_up_consignor_history_search = SignedUpConsignorSearch.new
          @signed_up_consignor_history_search.sale_id = params[:id]
          @signed_up_consignor_history_search.sort_order = ""
        else
          @signed_up_consignor_history_search.page = params[:page] || 1
        end
      elsif params[:signed_up_consignor_history_search].nil?
        @signed_up_consignor_history_search = SignedUpConsignorSearch.new
        @signed_up_consignor_history_search.sale_id = params[:id]
        @signed_up_consignor_history_search.sort_order = ""
      end
    end

    def clear_signed_up_consignor_history_search
      @signed_up_consignor_history_search = nil
      params[:signed_up_consignor_history_search] = nil
    end

    def create_new_signed_up_consignor_history_search
      @signed_up_consignor_history_search = SignedUpConsignorSearch.new(new_signed_up_consignor_history_search_params)
      @signed_up_consignor_history_search.page = params[:page] || 1
      @signed_up_consignor_history_search.sale_id = params[:id]
    end

    def new_signed_up_consignor_history_search_params
      params[:signed_up_consignor_history_search]
    end

    def save_signed_up_consignor_history_search
      session[:signed_up_consignor_history_search] = @signed_up_consignor_history_search
    end
  
    def search_consignor_history_profiles
      @consignors = @signed_up_consignor_history_search.profiles
    end
end
