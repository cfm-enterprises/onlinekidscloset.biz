class Admin::FranchisePhotosController < ApplicationController


  #Get /admin/franchise/:franchise_id/franchise_photos
  def index
    @franchise = Franchise.find(params[:franchise_id])
    @franchise_photo = FranchisePhoto.new
    @franchise_photo.franchise = @franchise
    @franchise_photos = @franchise.franchise_photos.paginate(:all, :page => params[:page], :order => 'asset_file_name')
    @frnchise_photo = FranchisePhoto.new
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def new
    
  end
  
  def edit
    @franchise_photo = FranchisePhoto.find(params[:id])
    @franchise = @franchise_photo.franchise
    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  # POST /admin/franchise/:franchise_id/franchise_photo/
  def create
    @franchise_photo = FranchisePhoto.new(params[:franchise_photo])
    @franchise = Franchise.find(params[:franchise_id])    
    @franchise_photo.franchise = @franchise

    uploaded_file_name = File.basename(params[:franchise_photo][:asset].original_filename)
    respond_to do |format|
      @franchise_photo.display_name = "#{@franchise_photo.franchise.sale_hash}_#{uploaded_file_name}"


      #validate that this is a valid image file
      if @franchise_photo.image_type?
        if @franchise_photo.save
          flash[:notice] = "Franchise Photo successfully Uploaded."
          format.html { redirect_to(admin_franchise_franchise_photos_url(@franchise_photo.franchise)) }
        else
          @franchise = @franchise_photo.franchise
          flash[:error] = "Could not upload photo file"
          format.html { render :action => 'new' }
        end
      else
        flash[:error] = "You must select a valid photo file."
        format.html { redirect_to(admin_franchise_franchise_photos_url(@franchise_photo.franchise)) }
      end
    end
        
  end

  # PUT /admin/franchsie/:franchise_id/franchise_photo/:id
  def update
    @franchise_photo = FranchisePhoto.find(params[:id])

    respond_to do |format|
      if @franchise_photo.update_attributes(params[:franchise_photo])
        flash[:notice] = 'Franchise Photo was successfully updated.'
        format.html { redirect_to(admin_franchise_franchise_photos_url(@franchise_photo.franchise)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /admin/franchises/:id/franchise_photo/:id
  def destroy
    @franchise_photo = FranchisePhoto.find(params[:id])
    respond_to do |format|
      if @franchise_photo.franchise_id == params[:franchise_id].to_i
        if @franchise_photo.site_asset.nil?
          @franchise_photo.destroy
        else
          @site_asset = @franchise_photo.site_asset
          @site_asset.destroy
        end
        flash[:warning] = "Franchise Photo was successfully deleted."
      else
        flash[:error] = "You are not authorized to delete that photo"
      end
      format.html { redirect_to(admin_franchise_franchise_photos_url(@franchise_photo.franchise)) }
    end
  end

end
