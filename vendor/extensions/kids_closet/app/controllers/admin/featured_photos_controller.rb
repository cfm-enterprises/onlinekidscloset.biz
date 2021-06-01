class Admin::FeaturedPhotosController < ApplicationController

	def create
		@sale = Sale.find(params[:sale_id])
		@featured_photo = FeaturedPhoto.new(params[:featured_photo])
    uploaded_file_name = File.basename(params[:featured_photo][:asset].original_filename) if params[:featured_photo][:asset]
    respond_to do |format|
	    if uploaded_file_name.empty_or_nil?
        flash[:warning] = 'Please select a file to upload'
	    else
        @featured_photo.display_name = "featured_item_#{@featured_photo.consignor_inventory.profile_id}_#{uploaded_file_name}"
        if @featured_photo.image_type?
          if @featured_photo.save
	          flash[:notice] = "New Featured Item Photo Uploaded Successfully"
	          FeaturedPhoto.rename_featured_file(@featured_photo.id)
					else
						flash[:error] = "Could not upload photo."
						@featured_photo.errors.full_messages.each { |msg| flash[:error] += "<br />&nbsp;&nbsp;&nbsp;&nbsp;#{msg}" }
					end
        else
	        flash[:error] = "You must select a valid photo file."
        end
      end
      format.html {redirect_to admin_sale_consignor_inventory_url(@sale, @featured_photo.consignor_inventory)}
    end 
	end

	def destroy
		photo = FeaturedPhoto.find(params[:id])
		sale = Sale.find(params[:sale_id])
		item = photo.consignor_inventory
		photo.destroy
    flash[:warning] = "Featured Photo was successfully deleted."
    respond_to do |format|	
    	format.html { redirect_to (admin_sale_consignor_inventory_url(sale, item)) }
    end
	end

	def rotate_clockwise
		sale = Sale.find(params[:sale_id])
		photo = FeaturedPhoto.find(params[:id])
		photo.rotate_clockwise
		photo.save
		flash[:notice] = "Selected Photo Rotated Clockwise"
		respond_to do |format|	
			format.html {redirect_to (admin_sale_consignor_inventory_url(sale, photo.consignor_inventory))}
		end
	end

	def rotate_counter_clockwise
		sale = Sale.find(params[:sale_id])
		photo = FeaturedPhoto.find(params[:id])
		photo.rotate_counter_clockwise
		photo.save
		flash[:notice] = "Selected Photo Rotated Counter Clockwise"
		respond_to do |format|	
			format.html {redirect_to (admin_sale_consignor_inventory_url(sale, photo.consignor_inventory))}
		end
	end
end
