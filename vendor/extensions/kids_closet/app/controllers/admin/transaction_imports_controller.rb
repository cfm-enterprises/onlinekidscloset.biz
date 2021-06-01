class Admin::TransactionImportsController < ApplicationController

  def new
    
  end

  #Get /admin/sale/:sale_id/transaction_imports
  def index
    @transaction_import = TransactionImport.new
    @transaction_import.sale = Sale.find(params[:sale_id])
    respond_to do |format|
      if @transaction_import.sale.start_date - 2 >= Date.today
        flash[:warning] = "Can not upload sale data until sale begins."
        format.html {redirect_to (admin_sale_url(@transaction_import.sale))}
      else      
#        @transaction_import.report_date = @transaction_import.sale.start_date
        @transaction_imports = @transaction_import.sale.transaction_imports.paginate(:all, :page => params[:page])
        @site_asset = SiteAsset.new
        format.html # index.html.erb
      end
    end
  end
  
  # POST /admin/sale/:sale_id/transaction_import/
  def create
    @transaction_import = TransactionImport.new(params[:transaction_import])

    lets_do_the_import = false
    TransactionImport.transaction do
      uploaded_file_name = File.basename(params[:site_asset][:asset].original_filename)
      @site_asset = SiteAsset.find_by_asset_file_name(uploaded_file_name)
      if @site_asset          
        #A duplicate was found that did not belong to this franchise
        conflicting_file_name = true
        flash[:warning] = "If you got this message after a short delay, the import is still running and financials will update shortly.  If you got this message immediately, it means that an import with the same file name has been previously imported.  Please double check.  If you need to re-import a file, please delete the existing import and then re-import."
      else
        @site_asset = SiteAsset.new(params[:site_asset])
      end
      @site_asset.display_name = "#{@transaction_import.sale.franchise.franchise_name}_#{uploaded_file_name}"

      #validate that this is a csv file
      unless conflicting_file_name
        if uploaded_file_name[-4, 4] == ".csv"
          @site_asset.save!
          @transaction_import.site_asset = @site_asset
          @transaction_import.status = "Scheduled to Import Transactions"
          @transaction_import.save!
          lets_do_the_import = true
        else
          flash[:error] = "You can only upload csv files for the import process."
        end
      end
    end
    if lets_do_the_import
      Delayed::Job.enqueue(
        KidsCloset::DoImport.new(@transaction_import.id), 0, 30.seconds.from_now
      )
    end
    respond_to do |format|
      format.html { redirect_to(admin_sale_transaction_imports_url(@transaction_import.sale)) }
    end
    
  rescue ActiveRecord::RecordInvalid => e
    flash[:error] = "There was an error in the import. #{e.record.errors.full_messages.join(", ")}"
    @transaction_import.valid?
    @transaction_import.destroy if lets_do_the_import
    @site_asset.destroy if lets_do_the_import
    respond_to do |format|
      format.html {redirect_to(admin_sale_transaction_imports_url(@transaction_import.sale)) }
    end
  end

  # GET /admin/transaction_imports/:id
  def edit
    @transaction_import = TransactionImport.find(params[:id])
    respond_to do |format|
      format.html #edit.html.erb
    end
  end

  #PUT /admin/transaction_imports/:id
  def update
    @transaction_import = TransactionImport.find(params[:id])
    
    respond_to do |format|
      if @transaction_import.update_attributes(params[:transaction_import])
        flash[:notice] = "Import Data Successfully Updated"
        format.html { redirect_to(admin_sale_transaction_imports_url(@transaction_import.sale)) }
      else
        format.html { render :action => 'edit'}
      end
    end
  end

  # DELETE /admin/sale/:sale_id/transaction_import/:id
  def destroy
    @transaction_import = TransactionImport.find(params[:id])
    respond_to do |format|
      if @transaction_import.sale_id == params[:sale_id].to_i
        Delayed::Job.enqueue(
          KidsCloset::UndoImport.new(@transaction_import.id), 0, 30.seconds.from_now
        )
        @transaction_import.status = "Scheduled for Deletion"
        @transaction_import.save
        flash[:warning] = "Transaction Import File is scheduled to be deleted."
      else
        flash[:error] = "You are not authorized to delete that transaction import"
      end
      format.html { redirect_to(admin_sale_transaction_imports_url(@transaction_import.sale)) }
    end
  end

  def log
    @transaction_import = TransactionImport.find(params[:id])
    @log_items = @transaction_import.items_sold.find(:all, :conditions => ["import_error_comment != ?", ''], :order => "import_error_comment")
    respond_to do |format|
      format.html #log.html
    end
  end
  
end
