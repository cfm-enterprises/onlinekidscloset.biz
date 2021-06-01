class Admin::ConsignorInventoriesController < ApplicationController
  
  # GET /admin/sale/:sale_id/consignor_inventories
  def index
    @sale = Sale.find(params[:sale_id])
    if params[:profile_id].not_nil? && params[:profile_id].not_blank?
      session[:inventory_consignor_search] = nil
      params[:consignor_search] = nil
    end
    if session[:inventory_item_id].not_nil? && params[:item_id].nil?
      params[:item_id] = session[:inventory_item_id]
    end
    if session[:inventory_item_name].not_nil? && params[:item_name].nil?
      params[:item_name] = session[:inventory_item_name]
    end
    if session[:inventory_profile_id].not_nil? && params[:profile_id].nil?
      params[:profile_id] = session[:inventory_profile_id]
    end
    if session[:inventory_consignor_search].not_nil? && params[:consignor_search].nil?
      params[:consignor_search] = session[:inventory_consignor_search]
    end
    if session[:inventory_transaction_date].not_nil? && params[:transaction_date].nil?
      params[:transaction_date] = session[:inventory_transaction_date]
    end
    if session[:inventory_import_id].not_nil? && params[:import_id].nil?
      params[:import_id] = session[:inventory_import_id]
    end
    if session[:inventory_transaction_number].not_nil? && params[:transaction_number].nil?
      params[:transaction_number] = session[:inventory_transaction_number]
    end
    if params[:item_id] || params[:item_name] || params[:profile_id] || params[:transaction_date] || params[:import_id] || params[:transaction_number]  || params[:consignor_search] || params[:rewards_number] || params[:purchaser_search]
      session[:inventory_item_id] = params[:item_id]
      session[:inventory_item_name] = params[:item_name]
      session[:inventory_profile_id] = params[:profile_id]
      session[:inventory_transaction_date] = params[:transaction_date]
      session[:inventory_import_id] = params[:import_id]
      session[:inventory_transaction_number] = params[:transaction_number]
      session[:inventory_consignor_search] = params[:consignor_search]
      session[:inventory_rewards_number] = params[:rewards_number]
      session[:inventory_purchaser_search] = params[:purchaser_search]
      conditions = ConsignorInventory.build_quick_conditions(params[:sale_id], params[:item_id], params[:item_name], params[:profile_id], params[:transaction_date], params[:import_id], params[:transaction_number], params[:consignor_search])
      @transactions = ConsignorInventory.quick_search(conditions, params[:page])
    else
      flash[:warning] = "Please use the form on the right to search for transactions"
      @transactions = ConsignorInventory.quick_search(["id = ?", 0], params[:page])
    end
    start_date = @sale.items_sold.minimum(:sale_date)
    end_date = @sale.items_sold.maximum(:sale_date)
    start_date = Date.today if start_date.nil?
    end_date = Date.today if end_date.nil?
    @date_options = []
    @date_options << ["All Transactions", nil]
    for date in start_date..end_date
      @date_options << [date.strftime("%b %d, %Y"), date]
    end
    consignors = @sale.consignor_profiles
    @consignors_array = []
    @consignors_array << ["All Consignors", nil]
    for consignor in consignors
      @consignors_array << [consignor.franchise_profile.profile.full_name, consignor.franchise_profile.profile_id]
    end
    @total_sold = ConsignorInventory.amount_sold_for_conditions(conditions)
    @tax_collected = ConsignorInventory.tax_collected_for_conditions(conditions)    
    @page_title = "Transaction Reports"
    if params[:profile_id].not_nil? && params[:profile_id].not_blank?
      consignor_number = params[:profile_id].to_i
    elsif params[:consignor_search].not_nil? && params[:consignor_search].not_blank?
      consignor_number = params[:consignor_search].to_i
    end
    if consignor_number.not_nil?
      @consignor_sign_up = @sale.consignor_profiles.find(:first, :conditions => ["profile_id = ?", consignor_number])
      if @consignor_sign_up.nil?
        flash[:error] = "The consignor number you searched for does not belong to your franchise."
      else
        @consignor_share = @total_sold * (@consignor_sign_up.sale_percentage.to_f / 100)
        @advertisement_fee = [@consignor_sign_up.sale_advert_cost, @consignor_share].min
        @page_title += " for #{@consignor_sign_up.franchise_profile.profile.full_name}"
      end
    end
    transaction_imports = @sale.transaction_imports
    @imports_array = []
    @imports_array << ["All Imports", nil]
    for import in transaction_imports
      @imports_array << [import.site_asset.nil? ? "Import #{import.id}" : import.site_asset.asset_file_name, import.id]
    end
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /admin/sale/:sale_id/consignor_inventory/:id
  def show
    @sale = Sale.find(params[:sale_id])
    @consignor_inventory = ConsignorInventory.find(params[:id])
    @featured_photo = FeaturedPhoto.new
    @featured_photo.consignor_inventory = @consignor_inventory
  end
  
  # GET /admin/sale/:sale_id/consignor_inventory/items_coming
  def items_coming
    @sale = Sale.find(params[:sale_id])
    session[:return_url] = request.request_uri
    if params[:profile_id].not_nil? && params[:profile_id].not_blank?
      session[:items_coming_inventory_consignor_search] = nil
      params[:consignor_search] = nil
    end
    if session[:items_coming_inventory_item_id].not_nil? && params[:item_id].nil?
      params[:item_id] = session[:items_coming_inventory_item_id]
    end
    if session[:items_coming_inventory_size].not_nil? && params[:size].nil?
      params[:size] = session[:items_coming_inventory_size]
    end
    if session[:items_coming_inventory_item_name].not_nil? && params[:item_name].nil?
      params[:item_name] = session[:items_coming_inventory_item_name]
    end
    if session[:items_coming_inventory_profile_id].not_nil? && params[:profile_id].nil?
      params[:profile_id] = session[:items_coming_inventory_profile_id]
    end
    if session[:items_coming_inventory_consignor_search].not_nil? && params[:consignor_search].nil?
      params[:consignor_search] = session[:items_coming_inventory_consignor_search]
    end
    if params[:item_id] || params[:item_name] || params[:profile_id] || params[:consignor_search] || params[:size]
      session[:items_coming_inventory_size] = params[:size]
      session[:items_coming_inventory_item_id] = params[:item_id]
      session[:items_coming_inventory_item_name] = params[:item_name]
      session[:items_coming_inventory_profile_id] = params[:profile_id]
      session[:items_coming_inventory_consignor_search] = params[:consignor_search]
      conditions = ConsignorInventory.build_items_coming_quick_conditions(params[:item_id], params[:item_name], params[:size], false, "")
      profile = Profile.find(params[:profile_id]) unless params[:profile_id].blank?
      profile = Profile.find(params[:consignor_search]) unless params[:consignor_search].blank?
      @items_coming = @sale.possible_sale_items_search(profile, conditions).paginate(:page => params[:page], :per_page => 25)
    else
      @items_coming = @sale.possible_sale_items.paginate(:page => params[:page], :per_page => 25)
    end
    consignors = @sale.consignor_profiles
    @consignors_array = []
    @consignors_array << ["All Consignors", nil]
    for consignor in consignors
      @consignors_array << [consignor.franchise_profile.profile.full_name, consignor.franchise_profile.profile_id]
    end
    @page_title = "Items Coming to Sale Report"
    if params[:profile_id].not_nil? && params[:profile_id].not_blank?
      consignor_number = params[:profile_id].to_i
    elsif params[:consignor_search].not_nil? && params[:consignor_search].not_blank?
      consignor_number = params[:consignor_search].to_i
    end
    if consignor_number.not_nil?
      @consignor_sign_up = @sale.consignor_profiles.find(:first, :conditions => ["profile_id = ?", consignor_number])
      if @consignor_sign_up.nil?
        flash[:error] = "The consignor number you searched for does not belong to your franchise."
      else
        @page_title += " for #{@consignor_sign_up.franchise_profile.profile.full_name}"
      end
    end
    respond_to do |format|
      format.html # items_coming.html.erb
    end
  end

  def items_selling_online
    @sale = Sale.find(params[:sale_id])
    session[:return_url] = request.request_uri
    if params[:profile_id].not_nil? && params[:profile_id].not_blank?
      session[:items_coming_inventory_consignor_search] = nil
      params[:consignor_search] = nil
    end
    if session[:items_coming_inventory_item_id].not_nil? && params[:item_id].nil?
      params[:item_id] = session[:items_coming_inventory_item_id]
    end
    if session[:items_coming_inventory_size].not_nil? && params[:size].nil?
      params[:size] = session[:items_coming_inventory_size]
    end
    if session[:items_coming_inventory_item_name].not_nil? && params[:item_name].nil?
      params[:item_name] = session[:items_coming_inventory_item_name]
    end
    if session[:items_coming_inventory_profile_id].not_nil? && params[:profile_id].nil?
      params[:profile_id] = session[:items_coming_inventory_profile_id]
    end
    if session[:items_coming_inventory_consignor_search].not_nil? && params[:consignor_search].nil?
      params[:consignor_search] = session[:items_coming_inventory_consignor_search]
    end
    if session[:items_coming_inventory_category_search].not_nil? && params[:category_search].nil?
      params[:category_search] = session[:items_coming_inventory_category_search]
    end
    if params[:item_id] || params[:item_name] || params[:profile_id] || params[:consignor_search] || params[:size] || params[:category_search]
      session[:items_coming_inventory_size] = params[:size]
      session[:items_coming_inventory_item_id] = params[:item_id]
      session[:items_coming_inventory_item_name] = params[:item_name]
      session[:items_coming_inventory_profile_id] = params[:profile_id]
      session[:items_coming_inventory_consignor_search] = params[:consignor_search]
      session[:items_coming_inventory_category_search] = params[:category_search]
      conditions = ConsignorInventory.build_items_coming_quick_conditions(params[:item_id], params[:item_name], params[:size], true, params[:category_search])
      profile = Profile.find(params[:profile_id]) unless params[:profile_id].blank?
      profile = Profile.find(params[:consignor_search]) unless params[:consignor_search].blank?
      @items_coming = @sale.possible_sale_items_search(profile, conditions).paginate(:page => params[:page], :per_page => 25)
    else
      @items_coming = @sale.featured_items.paginate(:page => params[:page], :per_page => 25)
    end
    consignors = @sale.consignor_profiles
    @consignors_array = []
    @consignors_array << ["All Consignors", nil]
    for consignor in consignors
      @consignors_array << [consignor.franchise_profile.profile.full_name, consignor.franchise_profile.profile_id]
    end
    @categories_array = []
    @categories_array << ["All Categories", nil]
    @categories_array = @categories_array + ConsignorInventory.category_array
    @page_title = "Items Coming to Online Sale Report"
    if params[:profile_id].not_nil? && params[:profile_id].not_blank?
      consignor_number = params[:profile_id].to_i
    elsif params[:consignor_search].not_nil? && params[:consignor_search].not_blank?
      consignor_number = params[:consignor_search].to_i
    end
    if consignor_number.not_nil?
      @consignor_sign_up = @sale.consignor_profiles.find(:first, :conditions => ["profile_id = ?", consignor_number])
      if @consignor_sign_up.nil?
        flash[:error] = "The consignor number you searched for does not belong to your franchise."
      else
        @page_title += " for #{@consignor_sign_up.franchise_profile.profile.full_name}"
      end
    end
    respond_to do |format|
      format.html # items_coming.html.erb
    end
  end

  #GET /admin//consignor_inventory/items_coming
  def edit
    @consignor_inventory = ConsignorInventory.find(params[:id])
    @sale = Sale.find(params[:sale_id])
    @featured_photo = FeaturedPhoto.new
    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  # PUT /admin/consignors_inventory/:id
  def update
    @consignor_inventory = ConsignorInventory.find(params[:id])
    @consignor_inventory.attributes = params[:consignor_inventory]
    @sale = Sale.find(params[:sale_id])

    uploaded_file_name = File.basename(params[:featured_photo][:asset].original_filename) if params[:featured_photo] && params[:featured_photo][:asset]

    if uploaded_file_name.empty_or_nil?
      respond_to do |format|
        if @consignor_inventory.save!
          flash[:notice] = 'Item was successfully updated.'
          format.html {redirect_to (session[:return_url])}
        else
          format.html { render :action => "edit" }
        end
      end
    else
      @featured_photo = FeaturedPhoto.new(params[:featured_photo])
      @featured_photo.display_name = "featured_item_#{@consignor_inventory.profile_id}_#{uploaded_file_name}"

      #validate that this is a valid image file
      respond_to do |format| 
        if @featured_photo.image_type?
          @consignor_inventory.featured_item = true
          @consignor_inventory.printed = false
            Delayed::Job.enqueue(
              KidsCloset::CreateBarcode.new(@consignor_inventory.id), 0, 30.seconds.from_now
            )
          @consignor_inventory.has_valid_photo = 1
          ConsignorInventory.transaction do  
            @consignor_inventory.save!
            @featured_photo.consignor_inventory_id = @consignor_inventory.id
            @featured_photo.save!
          end
          FeaturedPhoto.rename_featured_file(@featured_photo.id)
          flash[:notice] = "Item Saved and Uploaded Item Photo Successfully"
          format.html {redirect_to (session[:return_url])}
        else
          flash[:error] = "You must select a valid photo file."
          format.html { render :edit }
        end
      end
    end 
    rescue ActiveRecord::RecordInvalid => e
      respond_to do |format| 
        format.html { render :edit }
      end 
  end

  #DELETE /admin/consignor_inventory/remove_featured_item
  def remove_featured_item
      consignor_inventory = ConsignorInventory.find(params[:id])
      consignor_inventory.featured_item = false
      consignor_inventory.save
      respond_to do |format|
        format.html {redirect_to (session[:return_url])}
      end
  end

  # GET /admin/sale/:sale_id/consignor_inventory/items_coming
  def items_coming_export
    sale = Sale.find(params[:sale_id])
    params[:size] = session[:items_coming_inventory_size] if session[:items_coming_inventory_size].not_nil?
    params[:item_id] = session[:items_coming_inventory_item_id] if session[:items_coming_inventory_item_id].not_nil?
    params[:item_name] = session[:items_coming_inventory_item_name] if session[:items_coming_inventory_item_name].not_nil?
    params[:profile_id] = session[:items_coming_inventory_profile_id] if session[:items_coming_inventory_profile_id].not_nil?
    params[:consignor_search] = session[:items_coming_inventory_consignor_search] if session[:items_coming_inventory_consignor_search].not_nil?
    Delayed::Job.enqueue(
      KidsCloset::ItemsComingExport.new(params[:id], params[:item_id], params[:item_name], params[:profile_id], params[:consignor_search], params[:size], current_user.profile.email), 0, 2.seconds.from_now
    )
    flash[:notice] = "You will receive an email with a link to the export file shortly."
    
    respond_to do |format|
      format.html {redirect_to items_coming_admin_sale_consignor_inventory_url(sale, sale)}
    end
  end

  def return
    @consignor_inventory = ConsignorInventory.find(params[:id])
    if @consignor_inventory.sale_id == params[:sale_id].to_i
      Sale.calculate_sale_financials_after_refund(@consignor_inventory)
      flash[:notice] = "Item returned to consignor's available inventory"
    else
      flash[:error] = "Unauthorized"
    end      
    respond_to do |format|
      format.html {redirect_to admin_sale_consignor_inventories_url(params[:sale_id])}
    end    
  end

end
