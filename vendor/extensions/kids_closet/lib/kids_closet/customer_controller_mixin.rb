module KidsCloset
  module CustomerControllerMixin

    require 'csv'
    # GET /customer/become_consignor/:id
    def become_consignor
      franchise_profile = FranchiseProfile.find(:first, :conditions => ["profile_id = ? AND franchise_id = ?", current_profile_id, params[:id]])
      if franchise_profile.nil?
        franchise_profile = FranchiseProfile.new
        franchise_profile.profile_id = current_profile_id
        franchise_profile.franchise_id = params[:id]
        franchise_profile.new_consignor = true
      end
      franchise_profile.consignor = true
      franchise_profile.active = true
      franchise_profile.mailing_list = false
      if save_objeck(franchise_profile)
        FranchiseProfile.sign_up_to_consign_active_sale(franchise_profile)
        active_sale = franchise_profile.franchise.active_sale
        if active_sale.not_nil? && active_sale.has_online_sale
          email = KidsMailer.create_consignor_online_confirmation_email(active_sale, current_profile)
        else
          email = KidsMailer.create_consignor_confirmation_email(franchise_profile.franchise, current_profile, params[:id])
        end
        if KidsMailer.deliver(email)
          current_profile.histories.create(:message => "Consignor Thank You email sent")
        end
        subject = "A New Consignor has registered for your #{franchise_profile.franchise.franchise_name} sale!"
        email = KidsMailer.create_franchise_owner_notification_email(franchise_profile, subject)
        if KidsMailer.deliver(email)
          current_profile.histories.create(:message => "Consignor Thank You Confirmation email sent to owner")
        end
        flash[:notice] = "You are signed up to consign for the #{franchise_profile.franchise.franchise_name} sale."
        redirect_to "/sale/consignor_thank_you?sale_id=#{params[:id]}"
      else
        flash[:error] = "We could not sign you up for this franchise."
        redirect_to '/find_sale'
      end
    end

    def become_volunteer
      redirect_to "/consignors/helper_jobs?sale_id=#{params[:id]}"
    end

    def become_2017_volunteer
      redirect_to "/sale/volunteers_info?sale_id=#{params[:id]}#table_data_volunteer"
    end
    
    def sign_up_for_active_sale
      franchise_profile = FranchiseProfile.find(:first, :conditions => ["profile_id = ? AND franchise_id = ?", current_profile_id, params[:id]])
      if franchise_profile.consignor && franchise_profile.active
        FranchiseProfile.sign_up_to_consign_active_sale(franchise_profile)
        email = KidsMailer.create_consignor_confirmation_email(franchise_profile.franchise, current_profile, params[:id])
        if KidsMailer.deliver(email)
          current_profile.histories.create(:message => "Consignor Thank You email sent")
        end
        subject = "A New Consignor has registered for your #{franchise_profile.franchise.franchise_name} sale!"
        email = KidsMailer.create_franchise_owner_notification_email(franchise_profile, subject)
        if KidsMailer.deliver(email)
          current_profile.histories.create(:message => "Consignor Thank You Confirmation email sent to owner")
        end
        flash[:notice] = "You are now signed up to consign for the upcoming #{franchise_profile.franchise.franchise_name} sale."
        redirect_to "/consignors"
      else
        flash[:error] = "You are not an active consignor for this sale.  Please accept terms and agreements to consign."
        redirect_to "/sale/consign_register"
      end
    end
    
    # GET /customer/cancel_consignor/:id
    def cancel_consignor
      franchise_profile = FranchiseProfile.find(:first, :conditions => ["profile_id = ? AND franchise_id = ?", current_profile_id, params[:id]])
      unless franchise_profile.nil?
        franchise_profile.consignor = false
        franchise_profile.new_consignor = false
        franchise_profile.active = false unless franchise_profile.volunteer
        if save_objeck(franchise_profile)
          current_sale = Sale.current_active_sale(franchise_profile.franchise_id)
          if current_sale.start_date > Date.today
            sign_up = SaleConsignorSignUp.consignor_sign_up_for_sale(current_sale.id, franchise_profile.id)
            sign_up.destroy unless sign_up.nil?
            if franchise_profile.is_current_volunteer?
              unless franchise_profile.consignor && franchise_profile.items_coming > 0
                volunteer_jobs = SaleVolunteerSignUp.volunteer_sign_ups_for_sale(current_sale.id, franchise_profile.id)
                for job in volunteer_jobs
                  job.destroy
                end
              end
            end
            flash[:notice] = "You are no longer signed up to consign for the #{franchise_profile.franchise.franchise_name} sale."
            subject = "A Consignor has CANCELLED for your #{franchise_profile.franchise.franchise_name} sale."
            email = KidsMailer.create_franchise_owner_notification_email(franchise_profile, subject)
            KidsMailer.deliver(email)
          end
          redirect_to '/consignors'
        else
          flash[:error] = "We could not cancel your consignment."
          redirect_to '/consignors'
        end
      else
        show_failure(nil)
      end
    end
      
    # GET /customer/cancel_volunteer/:id
    def cancel_volunteer
      franchise_profile = FranchiseProfile.find(:first, :conditions => ["profile_id = ? AND franchise_id = ?", current_profile_id, params[:id]])
      unless franchise_profile.nil?
        franchise_profile.volunteer = false
        franchise_profile.active = false unless franchise_profile.consignor
        if save_objeck(franchise_profile)
          current_sale = Sale.current_active_sale(franchise_profile.franchise_id)
          if current_sale.start_date > Date.today
            volunteer_sign_ups = SaleVolunteerSignUp.volunteer_sign_ups_for_sale(current_sale.id, franchise_profile.id)
            volunteer_sign_ups.each do |sign_up|
              sign_up.destroy
            end
            flash[:notice] = "You are no longer signed up to help for the #{franchise_profile.franchise.franchise_name} sale."
          end
          subject = "A Helper has CANCELLED for your #{franchise_profile.franchise.franchise_name} sale!"
          email = KidsMailer.create_franchise_owner_volunteer_notification_email(franchise_profile, nil, subject)
          KidsMailer.deliver(email)
          redirect_to '/consignors'
        else
          flash[:error] = "We could not cancel your helper assignment."
          redirect_to '/consignors'
        end
      else
        show_failure(nil)
      end
    end

    def cancel_inactive_franchise
      franchise_profile = FranchiseProfile.find(:first, :conditions => ["profile_id = ? AND franchise_id = ?", current_profile_id, params[:id]])
      unless franchise_profile.nil?
        franchise_profile.volunteer = false
        franchise_profile.consignor = false
        franchise_profile.new_consignor = false
        franchise_profile.active = false
        if save_objeck(franchise_profile)
          current_sale = Sale.current_active_sale(franchise_profile.franchise_id)
          if current_sale.start_date > Date.today
            sign_up = SaleConsignorSignUp.consignor_sign_up_for_sale(current_sale.id, franchise_profile.id)
            sign_up.destroy unless sign_up.nil?
            volunteer_sign_ups = SaleVolunteerSignUp.volunteer_sign_ups_for_sale(current_sale.id, franchise_profile.id)
            volunteer_sign_ups.each do |sign_up|
              sign_up.destroy
            end
          end
          flash[:warning] = "The franchise has been removed from your history"
          redirect_to '/consignors'
        else
          flash[:error] = "We could not remove you from the franchise"
          redirect_to '/consignors'
        end
      end    
    end

    def select_drop_off_time
      drop_off_time = SaleConsignorTime.find(params[:id])
      franchise_profile = current_user.profile.franchise_profiles.find(:first, :conditions => ["franchise_id = ?", drop_off_time.sale.franchise_id])
      sale_consignor_sign_up = franchise_profile.sale_consignor_sign_ups.find(:first, :include => :sale_consignor_time, :conditions => ["sale_consignor_times.sale_id = ?", drop_off_time.sale_id])
      sale_consignor_sign_up ||= SaleConsignorSignUp.new
      sale_consignor_sign_up.sale_consignor_time = drop_off_time
      sale_consignor_sign_up.franchise_profile_id = franchise_profile.id
      if save_objeck(sale_consignor_sign_up)
        flash[:notice] = "Your drop off time has been set."
        redirect_to '/consignors'
      else
        flash[:error] = "We could not sign you up for that time."
        redirect_to "/consignors/drop_off_times?sale_id=#{drop_off_time.sale.franchise_id}"
      end
    end
    
    def select_volunteer_job
      volunteer_job = SaleVolunteerTime.find(params[:id])
      franchise_profile = current_user.profile.franchise_profiles.find(:first, :conditions => ["franchise_id = ?", volunteer_job.sale.franchise_id])
      if franchise_profile.nil?
        franchise_profile = FranchiseProfile.new
        franchise_profile.profile_id = current_profile_id
        
        franchise_profile.franchise_id = volunteer_job.sale.franchise_id
      end
      franchise_profile.volunteer = true
      franchise_profile.mailing_list = false
      franchise_profile.active = true
      if franchise_profile.save    
        sale_volunteer_sign_up = SaleVolunteerSignUp.new
        sale_volunteer_sign_up.sale_volunteer_time_id = volunteer_job.id
        sale_volunteer_sign_up.franchise_profile_id = franchise_profile.id
        if save_objeck(sale_volunteer_sign_up)
          body_html = "Thanks so much for being part of the upcoming #{franchise_profile.franchise.franchise_name} sale. Helpers are the lifeblood of a successful sale so we want to thank you in advance for your participation.<br><br>Some quick reminders:<ul><li>Please check in 10 minutes early to get briefed on your responsibilities.</li><li>If you need to cancel, please let us know as soon as possible. We rely on helpers and if you cancel at the last minute, it is very hard to find a replacement.  You can cancel by logging in to your control panel.</li><li>As a helper, you get to shop FIRST!  Make sure you note the <a href='http://www.kidscloset.biz/sale/sale_locations?sale_id=#{volunteer_job.sale.franchise_id}'>day and time</a> of our helper presale.</ul>Once again, we appreciate your time in helping us ensure the highest standards of children’s items that we sell, to assist shoppers and to help keep the sale orderly."
          subject = "Kid's Closet Connection - Helper Sign Up Confirmation"
          email = KidsMailer.create_general_mass_email(franchise_profile.franchise, nil, current_profile, subject, body_html, "Cancel Helping with Kid's Closet Connection.", "http://www.kidscloset.biz/consignors", "donotreply@kidscloset.biz")           
          if KidsMailer.deliver(email)
            current_profile.histories.create(:message => "Helper Thank You email sent")
          end
          subject = "A New Helper has registered for your #{franchise_profile.franchise.franchise_name} sale!"
          email = KidsMailer.create_franchise_owner_volunteer_notification_email(franchise_profile, sale_volunteer_sign_up.sale_volunteer_time, subject)
          KidsMailer.deliver(email)
          flash[:notice] = "Your Helper Job has been set."
          redirect_to '/consignors'
        else
          flash[:error] = "We could not sign you up for that job.  Make sure you have signed up to consign and have active items in your inventory."
          redirect_to "/sale/helpers_info?sale_id=#{volunteer_job.sale.franchise_id}#table_data_volunteer"
        end
      else
        flash[:error] = "We could not sign you up for that job."
        redirect_to "/consignors/helper_jobs?sale_id=#{volunteer_job.sale.franchise_id}"
      end
    end

    def cancel_volunteer_job
      volunteer_sign_up = SaleVolunteerSignUp.find(:first, :include => :franchise_profile, :conditions => ["franchise_profiles.profile_id = ? AND sale_volunteer_time_id = ?", current_profile.id, params[:id]])
      job = volunteer_sign_up.sale_volunteer_time
      unless volunteer_sign_up.nil?
        volunteer_sign_up.destroy
        subject = "A Helper has CANCELLED for your #{volunteer_sign_up.franchise_profile.franchise.franchise_name} sale!"
        email = KidsMailer.create_franchise_owner_volunteer_notification_email(volunteer_sign_up.franchise_profile, job, subject)
        KidsMailer.deliver(email)
        flash[:notice] = "Job successfully removed"
        redirect_to '/consignors'
      else
        flash[:error] = "Invalid job. Delete failed."
        show_failure(nil)
      end
    end
    
    def create_consignor_inventory
      consignor_inventory = ConsignorInventory.new(params[:consignor_inventory])
      consignor_inventory.profile_id = current_profile.id
      uploaded_file_name = File.basename(params[:featured_photo][:asset].original_filename) if params[:featured_photo] && params[:featured_photo][:asset]

      if uploaded_file_name.empty_or_nil?
        if consignor_inventory.save
          show_success("Inventory Item", "Created")
        else
          show_failure(consignor_inventory)
        end
      else
        featured_photo = FeaturedPhoto.new(params[:featured_photo])
        featured_photo.display_name = "featured_item_#{consignor_inventory.profile_id}_#{uploaded_file_name}"
        #validate that this is a valid image file
        if featured_photo.image_type?
          consignor_inventory.has_valid_photo = 1
          ConsignorInventory.transaction do  
            consignor_inventory.save!            
            featured_photo.consignor_inventory = consignor_inventory
            featured_photo.save!
          end
          FeaturedPhoto.rename_featured_file(featured_photo.id)
          flash[:notice] = "Online Sale Item created successfully.  Add up to 4 additional pictures below!"
          redirect_to "/consignors/item_detail?item_id=#{consignor_inventory.id}"
        else
          flash[:error] = "You must select a valid photo file."
          show_failure(consignor_inventory)
        end
      end   
    rescue ActiveRecord::RecordInvalid => e
      show_failure(consignor_inventory)
    end

    def create_voice_entry
      consignor_inventory = ConsignorInventory.voice_converstion(params[:voice_entry])
      params[:from_url] = "/consignors/adjust_voice_entry"
      params[:form_uuid] = "form_consignor_inventory"
      consignor_inventory.profile_id = current_profile.id
      save_and_show(consignor_inventory, "Inventory Item")
    end

    def update_consignor_inventory
      if current_profile.item_ids.include? params[:id].to_i
        item = ConsignorInventory.find(params[:id])
        if item.status || item.donate_date.not_nil?
          flash[:error] = "Can not edit sold or donated items"
          redirect_to "/consignors"
        else
          begin
            File.delete(item.barcode_file_path) if File.exists?(item.barcode_file_path)
          rescue

          end

          item.attributes = params[:consignor_inventory]

          uploaded_file_name = File.basename(params[:featured_photo][:asset].original_filename) if params[:featured_photo] && params[:featured_photo][:asset]

          if uploaded_file_name.empty_or_nil?
            item.printed = false
            Delayed::Job.enqueue(
              KidsCloset::CreateBarcode.new(item.id), 0, 30.seconds.from_now
            )
            if item.save
              if item.featured_item
                flash[:notice] = "Online Sale Item Updated Successfully"
                redirect_to "/consignors/item?consignor_inventory_id=#{item.id}"
              else                
                show_success("Inventory Item", "Updated")
              end
            else
              show_failure(item)
            end
          else
            item.has_valid_photo = 0
            featured_photo = FeaturedPhoto.new(params[:featured_photo])
            featured_photo.display_name = "featured_item_#{item.profile_id}_#{uploaded_file_name}"

            #validate that this is a valid image file
            if featured_photo.image_type?
              item.featured_item = true
              item.printed = false
              Delayed::Job.enqueue(
                KidsCloset::CreateBarcode.new(item.id), 0, 30.seconds.from_now
              )
              ConsignorInventory.transaction do  
                item.save!
                featured_photo.consignor_inventory_id = item.id
                featured_photo.save!
              end
              FeaturedPhoto.rename_featured_file(featured_photo.id)
              flash[:notice] = "Online Sale Item Updated Successfully and Photo Uploaded Successfully"
              redirect_to "/consignors/item?consignor_inventory_id=#{item.id}"
            else
              show_failure(item)
            end
          end
        end
      else
        flash[:error] = "Invalid inventory id. Update failed."
        show_failure(nil)
      end
    rescue ActiveRecord::RecordInvalid => e
      show_failure(item)
    end
    
    def destroy_item
      @redirect_url = "/consignors/inventory?page=#{params[:page]}"
      destroy_the_item
    end
    
    def destroy_inactive_item
      @redirect_url = "/consignors/inactive_inventory?page=#{params[:page]}"
      destroy_the_item
    end
    
    def destroy_active_items
      active_items = current_profile.active_items.find(:all)
      for item in active_items
        item.destroy
      end
      flash[:notice] = "All items marked as coming to the sale have been deleted from your inventory."
      redirect_to '/consignors/inventory'
    end
    
    def destroy_inactive_items
      inactive_items = current_profile.inactive_items.find(:all)
      for item in inactive_items
        item.destroy
      end
      flash[:notice] = "All items marked as not coming to sale have been deleted from your inventory."
      redirect_to '/consignors/inactive_inventory'
    end

    def donate_item
      @redirect_url = "/consignors/inventory?page=#{params[:page]}"
      donate_the_item
    end          
    
    def donate_inactive_item
      @redirect_url = "/consignors/inactive_inventory?page=#{params[:page]}"
      donate_the_item
    end          
    
    def donate_all_items
      active_items_to_donate = current_profile.active_items.find(:all, :conditions => ["donate = ?", true])
      for item in active_items_to_donate
        item.donate_date = Date.today
        item.save
      end
      flash[:notice] = "All active items eligible for donation have been marked as donated."
      redirect_to '/consignors/inventory'
    end

    def donate_all_inactive_items
      inactive_items_to_donate = current_profile.inactive_items.find(:all, :conditions => ["donate = ?", true])
      for item in inactive_items_to_donate
        item.donate_date = Date.today
        item.save
      end
      flash[:notice] = "All active items eligible for donation have been marked as donated."
      redirect_to '/consignors/inventory'
    end

    def rewards_profile
      rewards_profile = RewardsProfile.find(:first, :conditions => ["rewards_number = ?", params[:rewards_profile][:rewards_number]])
      if rewards_profile.nil?
        flash[:error] = "The Rewards Number You Entered is not in our System. If the number you entered is correct, please wait up to 24 hours for our system to update todays's sale data."
        show_failure(nil)
      else
        if rewards_profile.profile.nil?
          rewards_profile.profile_id = current_profile.id
          rewards_profile.rewards_number_confirmation = params[:rewards_profile][:rewards_number_confirmation]
        end
        if rewards_profile.profile_id == current_profile.id
          rewards_profile.primary_card = true #make sure it saves
          if save_objeck(rewards_profile)
            body = "Thank you for registering your Closet Cash card.  To ensure you receive future emails from Kid’s Closet Connection, please add this email address to your safe sender list."
            subject = "Kid's Closet Connection - Rewards Card Claim Confirmation"
            email = KidsMailer.create_general_mass_email(nil, nil, current_profile, subject, body, "", "", "donotreply@kidscloset.biz")           
            if KidsMailer.deliver(email)
              current_profile.histories.create(:message => "Rewards Card Claim Confirmation email sent")
            end            
            show_success("Closet Cash Rewards Card", "claimed")
          else
            flash[:error] = "We could not change the rewards status."
            show_failure(rewards_profile)            
          end
        else
          flash[:error] = "Invalid Rewards Number"
          show_failure(nil)
        end
      end      
    end
  
    # Post /customer/make_card_primary/:id/
    def make_card_primary
      rewards_profile = RewardsProfile.find(params[:id])
      if rewards_profile.profile_id == current_profile.id
      rewards_profile.primary_card = true
        if save_objeck(rewards_profile)
          flash[:notice] = "Your primary card is set.  Awards will be applied to this card."
          redirect_to '/rewards/rewards_center'
        else
          flash[:error] = "We could not change the rewards primary card status."
          redirect_to '/rewards/rewards_center'
        end
      else
        show_failure(nil)
      end
    end

    # GET /admin/consignor_inventories/print_tags
    def print_new_tags
      @consignor_items = current_user.profile.active_items.find(:all, :conditions => ["printed = ?", false], :limit => 80)
      @consignor_barcodes = []
      @consignor_items.each do |item|
        ConsignorInventory.create_barcode(item) unless File.exists?(item.barcode_file_path)
        if !item.printed
          item.printed = true
          item.save
        end
      end
      @right_side = false
      @row_count = 0
      respond_to do |format|
        format.html {render :layout => 'tags', :action => 'print_new_tags'}# print_new_tags.html.erb
        format.pdf {render  :template => 'customer/print_new_tags.pdf.erb',
                            :pdf => "consignor_tags.pdf",
                            :layout => 'tags.html',
                            :page_size => 'Letter',
                            :margin => {
                              :top                => 0,
                              :bottom             => 0,
                              :left               => 10,
                              :right              => 10}                            
                    }         
      end
    end

    def print_online_sell_tags
      @sold_items = current_user.profile.sells.find(:all, :conditions => ["created_at > ?", Time.now - 15 * 24 * 60 * 60])
      @consignor_items = []
      @consignor_barcodes = []
      @sold_items.each do |order|
        unless order.consignor_inventory.nil?
          item = order.consignor_inventory
          if !item.printed
            item.printed = true
            item.save
            @consignor_items << item
          end
        end
      end
      @right_side = false
      @row_count = 0
      respond_to do |format|
        format.html {render :layout => 'tags', :action => 'print_online_tags'}# print_new_tags.html.erb
        format.pdf {render  :template => 'customer/print_online_tags.pdf.erb',
                            :pdf => "consignor_tags.pdf",
                            :layout => 'tags.html',
                            :page_size => 'Letter',
                            :margin => {
                              :top                => 0,
                              :bottom             => 0,
                              :left               => 10,
                              :right              => 10}                            
                    }         
      end
    end
  
    def print_selected_tags
      if params["success_url"] == "/consignors/inventory"
        @active_consignor_items = current_user.profile.active_items
      else
        @active_consignor_items = current_user.profile.inactive_items
      end
      @consignor_items = []
      for possible_item in @active_consignor_items
        if params["item_#{possible_item.id}"] == "1"
          if params["submit_action"] == "print"
            ConsignorInventory.create_barcode(possible_item) unless File.exists?(possible_item.barcode_file_path)
            if !possible_item.printed
              possible_item.printed = true
              possible_item.save
            end          
            @consignor_items << possible_item
          elsif params["submit_action"] == "bring_to_sale"
            possible_item.bring_to_sale = true
            possible_item.save
          elsif params["submit_action"] == "inactivate_item"
            possible_item.bring_to_sale = false
            possible_item.save
          else
            possible_item.destroy
          end
        end
      end
      @right_side = false
      @row_count = 0
      if params["submit_action"] == "print"
        respond_to do |format|
          format.html {render :layout => 'tags', :action => 'print_new_tags'}# print_new_tags.html.erb
          format.pdf {render  :template => 'customer/print_new_tags.pdf.erb',
                              :pdf => "consignor_tags.pdf",
                              :layout => 'tags.html',
                              :page_size => 'Letter',
                              :margin => {
                                :top                => 0,
                                :bottom             => 0,
                                :left               => 10,
                                :right              => 10}
                      }         
        end
      else
        page = params[:page]
        page = 1 if page.empty_or_nil?
        redirect_to "#{params[:success_url]}?page=#{page}"
      end        
    end

    def print_selected_online_tags
      @active_sells = current_user.profile.sells      
      @consignor_items = []
      for sell in @active_sells
        possible_item = sell.consignor_inventory
        if params["item_#{possible_item.id}"] == "1"
          if !possible_item.printed
            possible_item.printed = true
            possible_item.save
          end          
          @consignor_items << possible_item
        end
      end
      @right_side = false
      @row_count = 0
      respond_to do |format|
        format.pdf {render  :template => 'customer/print_online_tags.pdf.erb',
                            :pdf => "consignor_tags.pdf",
                            :layout => 'tags.html',
                            :page_size => 'Letter',
                            :margin => {
                              :top                => 0,
                              :bottom             => 0,
                              :left               => 10,
                              :right              => 10}
                    }         
      end
    end

    def print_selected_tag
      item = ConsignorInventory.find(params[:id])
      if !item.printed
        item.printed = true
        item.save
      end          
      @consignor_items = []
      @consignor_items << item
      @right_side = false
      @row_count = 0
      respond_to do |format|
        format.pdf {render  :template => 'customer/print_online_tags.pdf.erb',
                            :pdf => "consignor_tags.pdf",
                            :layout => 'tags.html',
                            :page_size => 'Letter',
                            :margin => {
                              :top                => 0,
                              :bottom             => 0,
                              :left               => 10,
                              :right              => 10}
                    }         
      end
    end
  
    def download_active_inventory
      active_consignor_items = current_user.profile.active_items
      csv_string = FasterCSV.generate do |csv|
        csv << ['Item #', 'Description', 'Size', 'Price', 'Sell Online', 'Active', 'Last Day Discount', 'Donate']
        for item in active_consignor_items
          csv << [item.id, item.item_description, item.size, item.price, item.featured_item ? "Yes" : "No", item.bring_to_sale ? "Yes" : "No", item.last_day_discount ? "Yes" : "No", item.donate ? "Yes" : "No" ]
        end
      end
      send_data csv_string,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=active_items.csv"          
    end

    def download_inactive_inventory
      inactive_consignor_items = current_user.profile.inactive_items
      csv_string = FasterCSV.generate do |csv|
        csv << ['Item #', 'Description', 'Size', 'Price', 'Last Day Discount', 'Donate']
        for item in inactive_consignor_items
          csv << [item.id, item.item_description, item.size, item.price, item.last_day_discount ? "Yes" : "No", item.donate ? "Yes" : "No" ]
        end
      end
      send_data csv_string,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=inactive_items.csv"          
    end

    def donate_the_item
      if current_profile.item_ids.include? params[:id].to_i
        consignor_inventory = ConsignorInventory.find(params[:id])
        if !consignor_inventory.status && consignor_inventory.donate
          consignor_inventory.donate_date = Date.today
          if consignor_inventory.save
            flash[:notice] = "Item added to donated list"
            redirect_to @redirect_url
          else
            flash[:error] = "We could not donate this item"
            redirect_to @redirect_url
          end
        else
          flash[:warning] = "Item did not qualify for donation"
          redirect_to @redirect_url
        end
      else
        flash[:error] = "Invalid inventory id. Donation failed."
        show_failure(nil)
      end
    end

    def make_active_item
      @item_status = "Bring to Sale"
      @redirect_url = "/consignors/inactive_inventory"
      change_bring_to_sale_status(true)
    end

    def make_inactive_item
      @item_status = "Inactive"
      @redirect_url = "/consignors/inventory"
      change_bring_to_sale_status(false)
    end

    def make_item_not_featured
      page = params[:page]
      page = 1 if page.empty_or_nil?
      if current_profile.item_ids.include? params[:id].to_i    
        item = ConsignorInventory.find(params[:id])
        item.featured_item = false
        item.save
        flash[:notice] = "Item removed from featured list"
        redirect_to  "/consignors/featured_items?page=#{params[:page]}"
      else
        flash[:error] = "Invalid inventory id. Make not featured failed."
        show_failure(nil)
      end    
    end

    def change_bring_to_sale_status(bring_to_sale)
      page = params[:page]
      page = 1 if page.empty_or_nil?
      if current_profile.item_ids.include? params[:id].to_i
        item = ConsignorInventory.find(params[:id])
        if item.status || item.donate_date.not_nil?
          flash[:error] = "Can not inactivate sold or donated items"
          redirect_to '/consignors'
        else
          item.bring_to_sale = bring_to_sale
          if item.save
            flash[:notice] = "Item added to '#{@item_status}' list"
            redirect_to  "#{@redirect_url}?page=#{params[:page]}"
          else
            flash[:error] = "We could not change the item status to '#{@item_status}'"
            redirect_to  "#{@redirect_url}?page=#{params[:page]}"
          end
        end
      else
        flash[:error] = "Invalid inventory id. Make active failed."
        show_failure(nil)
      end    
    end

    def destroy_the_item
      if current_profile.item_ids.include? params[:id].to_i
        item = ConsignorInventory.find(params[:id])
        if item.status || item.donate_date.not_nil?  || item.order.not_nil?
          flash[:error] = "Can not delete sold or donated items"
          redirect_to '/consignors'
        else
          item.destroy
          flash[:notice] = "Item deleted successfully"
          redirect_to @redirect_url
        end
      else
        flash[:error] = "Invalid inventory id. Delete failed."
        show_failure(nil)
      end    
    end

    def purchase_item_with_paypal
      item = ConsignorInventory.find(params[:id])
      franchise = Franchise.find(params[:franchise_id])
      sale = franchise.active_sale
      order = Order.new
      order.consignor_inventory_id = item.id
      order.item_name = item.item_description
      order.item_price = item.price
      order.item_price = (order.item_price * 0.5).round(2) if sale.is_on_50_percent_discount? && item.last_day_discount 
      order.item_price = (order.item_price * 0.75).round(2) if sale.is_on_25_percent_discount? && item.last_day_discount 
      order.sales_tax = (order.item_price * sale.tax_rate / 100.0).round(2)
      order.total_amount = order.item_price + order.sales_tax
      order.sale = sale
      order.buyer = current_user.profile
      order.seller = item.profile
      order.ordered_at = Time.now
      if order.save
        flash[:notice] = "The item has been added to your shopping cart."
        redirect_to "/consignors/shopping_cart?new_item=1"
      else
        flash[:error] = ""
        order.errors.full_messages.each { |msg| flash[:error] += "#{msg}" } 
        redirect_to "/sale/online_sale?sale_id=#{sale.franchise_id}"
      end
    end

    def process_shopping_cart
      franchise = Franchise.find(params[:franchise_id])
      sale = franchise.active_sale
      items = current_user.profile.pending_orders_for_sale(sale.id)
      if items.count > 0
        pay_pal_order = PayPalOrder.new
        pay_pal_order.sale = sale
        pay_pal_order.profile = current_user.profile
        pay_pal_order.ordered_at = Time.now
        if pay_pal_order.save
          for item in items
            item.pay_pal_order_id = pay_pal_order.id
            item.save
          end
          flash[:notice] = "Please click on the Checkout with PayPal button to complete your payment with PayPal."
          redirect_to "/consignors/check_out"
        else
          flash[:error] = ""
          order.errors.full_messages.each { |msg| flash[:error] += "#{msg}" } 
          redirect_to "/sale/online_sale?sale_id=#{sale.franchise_id}"
        end
      else
        redirect_to "/consignors/check_out"
      end
    end

    def complete_purchase
      begin 
        order = PayPalOrder.find(params[:id])
      rescue
        flash[:warning] = "Transaction expired. Please try again."
        redirect_to "/consignors/shopping_cart"
        return
      end
      if order.purchased_at.nil?
        Order.transaction do
          order.purchased_at = Time.now
          order.save!
          for item_ordered in order.orders
            item_ordered.purchased_at = Time.now
            item_ordered.save!
            item = item_ordered.consignor_inventory
            item.sale_id = item_ordered.sale_id
            item.discounted_at_sale = 0
            item.sale_price = item_ordered.item_price
            item.tax_collected = item_ordered.sales_tax
            item.total_price = item_ordered.total_amount
            item.sale_date = Date.today
            item.status = true
            item.sold_online = true
            item.save!
            current_profile.histories.create(:message => "Purchase for Item Number #{item.id} Completed")            
          end
          email = KidsMailer.create_purchase_confirmation_email(order)
          KidsMailer.deliver(email)
          for item_ordered in order.orders
            email = KidsMailer.create_sale_notification_email(item_ordered)
            KidsMailer.deliver(email)
            item_ordered.seller.histories.create(:message => "Sell for Item Number #{item_ordered.consignor_inventory_id} Completed")
          end
          email = KidsMailer.create_owner_purchase_notification(order)
          KidsMailer.deliver(email)
        end
      end
      flash[:notice] = "Payment successful"
	    redirect_to "/sale/order_confirmation?sale_id=#{order.sale.franchise_id}&order_id=#{order.id}"

    rescue ActiveRecord::RecordInvalid => e
      flash[:warning] = "Transaction completed but there was a system error."
      redirect_to "/sale/online_sale?sale_id=#{order.sale.franchise_id}"
    end

    def cancel_purchase
      order = PayPalOrder.find(params[:id])
      if order.purchased_at.nil? 
        order.destroy
        flash[:notice] = "You can now add or remove items from the cart."
        redirect_to "/consignors/shopping_cart"
      else
        franchise_id = order.sale.franchise_id
        flash[:notice] = "This order was already completed."
        redirect_to "/sale/online_sale?sale_id=#{franchise_id}"
      end
    end

    def create_featured_photo
      @featured_photo = FeaturedPhoto.new(params[:featured_photo])
      uploaded_file_name = File.basename(params[:featured_photo][:asset].original_filename) if params[:featured_photo][:asset]
      if uploaded_file_name.empty_or_nil?
        flash[:warning] = 'Please select a file to upload'
      else
        @featured_photo.display_name = "featured_item_#{@featured_photo.consignor_inventory.profile_id}_#{uploaded_file_name}"
        if @featured_photo.image_type?
          if @featured_photo.save
            FeaturedPhoto.rename_featured_file(@featured_photo.id)
            flash[:notice] = "New Online Sale Item Photo Uploaded Successfully"
          else
            flash[:error] = "Could not upload photo."
            @featured_photo.errors.full_messages.each { |msg| flash[:error] += "<br />&nbsp;&nbsp;&nbsp;&nbsp;#{msg}" }
          end
        else
          flash[:error] = "You must select a valid photo file."
        end
      end
      params[:page] = 1 if params[:page].empty_or_nil?
      redirect_to "/consignors/item?consignor_inventory_id=#{@featured_photo.consignor_inventory_id}&page=#{params[:page]}&added_photo=true"
    end

    def delete_featured_photo
      photo = FeaturedPhoto.find(params[:id])
      item = photo.consignor_inventory
      photo.destroy
      flash[:warning] = "Online Sale Item Photo was successfully deleted."
      params[:page] = 1 if params[:page].empty_or_nil?
      redirect_to "/consignors/item?consignor_inventory_id=#{item.id}&page=#{params[:page]}"
    end

    def rotate_featured_photo_clockwise
      photo = FeaturedPhoto.find(params[:id])
      photo.rotate_clockwise
      photo.save
      flash[:notice] = "Selected Photo Rotated Clockwise"
      params[:page] = 1 if params[:page].empty_or_nil?
      redirect_to "/consignors/item?consignor_inventory_id=#{photo.consignor_inventory_id}&page=#{params[:page]}"
    end

    def rotate_featured_photo_counter_clockwise
      photo = FeaturedPhoto.find(params[:id])
      photo.rotate_counter_clockwise
      photo.save
      flash[:notice] = "Selected Photo Rotated Counter Clockwise"
      params[:page] = 1 if params[:page].empty_or_nil?
      redirect_to "/consignors/item?consignor_inventory_id=#{photo.consignor_inventory_id}&page=#{params[:page]}" 
    end

    def delete_cart_item
      order = Order.find(params[:id])
      if order.pay_pal_order.nil?
        order.destroy
        flash[:notice] = "Item removed from shopping cart."
      else
        flash[:error] = "You cannot remove this item because the payment is in process.  If you need to remove it, please contact the sale owner at the email listed below."
      end
      redirect_to "/consignors/shopping_cart"
    end
  end
end