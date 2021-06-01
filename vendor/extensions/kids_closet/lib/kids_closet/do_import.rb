module KidsCloset
  require 'csv'

  class DoImport < Struct.new(:transaction_import_id)

    def perform
      Site.current_site_id = 1
      @transaction_import = TransactionImport.find(transaction_import_id)
      @sale_id = @transaction_import.sale_id
      franchise_id = @transaction_import.sale.franchise_id
      internal_drop_off_time_id = SaleConsignorTime.internal_time_for_sale(@sale_id)
      import_file = File.open(@transaction_import.site_asset.file_path, "r") { |f| f.read }
      parsed_file = CSV::Reader.parse(import_file)
      @transaction_import.status = "Verifying Consignors"
      @transaction_import.save

#do two passes, first pass should add profiles and such.  Second run should add actual transactions
      parsed_file.each do |row|
        if !row[0].nil? && !row[4].nil?
          # read data
          @profile_id = row[2].to_i
          @profile_id = @profile_id - 8913365 if @profile_id >= 8953099 && @profile_id <= 8953199
          # verify consignor exists, if not add a profile for the consignor

          unless Profile.find(:first, :conditions => ["id = ?", @profile_id]).nil?
            @franchise_profile = FranchiseProfile.find(:first, :conditions => ["profile_id = ? AND franchise_id = ?", @profile_id, franchise_id])  
            create_franchise_profile(franchise_id) if @franchise_profile.nil? #consignor has not signed up for this franchise
            sign_up_consignor_to_franchise unless @franchise_profile.consignor && @franchise_profile.active #make sure consignor is active and signed up to consigned, update otherwise
            
            #now verify consignor signed up for a drop off time
            create_consignor_sign_up(internal_drop_off_time_id) if SaleConsignorSignUp.consignor_sign_up_for_sale(@sale_id, @franchise_profile.id).nil? #consignor did not sign up for a drop off time, add consignor to internal group            
          end         
        end
      end            

#this pass now we actually import the data and handle profiles that don't exist.
      @transaction_import.status = "Processing Data"
      @transaction_import.save
#      start_time = Time.now
      item_count = 1000
      TransactionImport.transaction do
        parsed_file.each do |row|
          if !row[0].nil? && !row[4].nil?
            # read data
          #start information string
          item_count += 1
#          string = "Item #{item_count} Read CSV #{Time.now - start_time}"
            @date = row[0].to_date
            @transaction_number = row[1]
            @profile_id = row[2].to_i
            @profile_id = @profile_id - 8913365 if @profile_id >= 8953099 && @profile_id <= 8953199
            @consignor_inventory_id = row[3].to_i
            @price = row[4].to_i
            @applied_discount = row[5].to_f == 0.5 ? true : false
            @sale_price = row[6].delete "$"
            @tax_collected = row[7].delete "$"
            @total_price = row[8].delete "$"
            rewards_number = row[9].to_i
            @rewards_number = rewards_number == 0 ? nil : rewards_number
    
            #now find the item being imported
          #load item
#          string += "Load Item #{Time.now - start_time}"
            @consignor_inventory = ConsignorInventory.find(:first, :conditions => ["id = ?", @consignor_inventory_id])
            if @consignor_inventory.nil? #Item doesn't exist, add a new one
              create_new_inventory("")
            elsif @consignor_inventory.status
              create_new_inventory("Original Item #{@consignor_inventory_id} was marked as sold by another import.  Added new item.")
            elsif @consignor_inventory.profile_id != @profile_id
              create_new_inventory("Original Item #{@consignor_inventory_id} belongs to another consignor.  Added new item.")
#            elsif @consignor_inventory.price.to_i != @price
#              create_new_inventory("Original Item #{@consignor_inventory_id} had a different price.  Added new item.")
            end
  
            # verify consignor exists, if not add a profile for the consignor
          #load item
#          string += "Load Profile #{Time.now - start_time}"
            if Profile.find(:first, :conditions => ["id = ?", @profile_id]).nil?
              # try to see if the inventory consignor id works
              if Profile.find(:first, :conditions => ["id = ?", @consignor_inventory.profile_id]).nil?
                @profile_id = ""
                @error_profile_id = @consignor_inventory.profile_id
                @consignor_inventory.profile_id = nil
              else
                @profile_id = @consignor_inventory.profile_id
              end
            end
            
          #load item
#          string += "Verify Consigning #{Time.now - start_time}"
            #now verify consignor has signed up for this franchise
            @franchise_profile = FranchiseProfile.find(:first, :conditions => ["profile_id = ? AND franchise_id = ?", @profile_id, franchise_id])  
            create_franchise_profile(franchise_id) if @franchise_profile.nil? #consignor has not signed up for this franchise
            sign_up_consignor_to_franchise unless @franchise_profile.consignor && @franchise_profile.active #make sure consignor is active and signed up to consigned, update otherwise
            
            #now verify consignor signed up for a drop off time
            create_consignor_sign_up(internal_drop_off_time_id) if SaleConsignorSignUp.consignor_sign_up_for_sale(@sale_id, @franchise_profile.id).nil? #consignor did not sign up for a drop off time, add consignor to internal group
            
            #verify that we have a rewards account created for the rewards number
            unless @rewards_number.nil?
              @rewards_profile = RewardsProfile.find(:first, :conditions => ["rewards_number = ?", @rewards_number])
              create_rewards if @rewards_profile.nil?
            end
            
  
          #load item
#          string += "Update Item #{Time.now - start_time}"
            #update item with sale information
            @consignor_inventory.transaction_import_id = @transaction_import.id
            @consignor_inventory.sale_id = @sale_id
            @consignor_inventory.discounted_at_sale = @applied_discount
            @consignor_inventory.sale_price = @sale_price
            @consignor_inventory.tax_collected = @tax_collected
            @consignor_inventory.total_price = @total_price
            @consignor_inventory.sale_date = @date
            @consignor_inventory.transaction_number = @transaction_number
            @consignor_inventory.rewards_profile_id = @rewards_profile.id unless @rewards_number.nil?
            @consignor_inventory.status = true
#          string += "Save Item #{Time.now - start_time}"
#            @consignor_inventory.import_error_comment = string
            @consignor_inventory.save!    
          end
        end            
        #mark import as processed
      end
      @transaction_import.processed = true
      @transaction_import.status = "Processing Sale Financials"
      @transaction_import.save
      @transaction_import.sale.calculate_financials
      @transaction_import.status = "Adding Phone Numbers"
      @transaction_import.save

      parsed_file.each do |row|
        if !row[0].nil? && !row[4].nil? && !row[9].nil?
          # read data
          @texting_number = row[9]
          franchise_text_number = FranchiseTextingProfile.new
          franchise_text_number.franchise_id = franchise_id
          franchise_text_number.phone = @texting_number
          franchise_text_number.save
        end
      end

      @transaction_import.status = "Complete"
      @transaction_import.save


    rescue ActiveRecord::RecordInvalid => e
      @transaction_import.status = "There was an error in the import. #{e.record.errors.full_messages.join(", ")}"
      if @error_profile_id.not_blank?
        @transaction_import.status += ". Invalid consignor number was #{@error_profile_id}"
      end
      @transaction_import.save
    end

    def create_new_inventory(error_message)
      @consignor_inventory = ConsignorInventory.new
      @consignor_inventory.profile_id = @profile_id
      @consignor_inventory.price = @price
      @consignor_inventory.item_description = "Unscannable Item-Added by System ##{@transaction_import.id}"
      @consignor_inventory.last_day_discount = @applied_discount
      @consignor_inventory.donate = false
      @consignor_inventory.import_error_comment = error_message
      @consignor_inventory.bring_to_sale = false
    end
    
    def create_rewards
      @rewards_profile = RewardsProfile.new
      @rewards_profile.rewards_number = @rewards_number
      @rewards_profile.rewards_number_confirmation = @rewards_number
      unless @rewards_profile.save
        @rewards_number = nil
      end     
    end

    def create_franchise_profile(franchise_id)
      @franchise_profile = FranchiseProfile.new
      @franchise_profile.profile_id = @profile_id
      @franchise_profile.franchise_id = franchise_id
      @franchise_profile.consignor = true
      @franchise_profile.active = true
      @franchise_profile.save      
    end

    def sign_up_consignor_to_franchise
      @franchise_profile.consignor = true
      @franchise_profile.active = true
      @franchise_profile.save
    end

    def create_consignor_sign_up(internal_drop_off_time_id)
      consignor_sign_up = SaleConsignorSignUp.new
      consignor_sign_up.franchise_profile_id = @franchise_profile.id
      consignor_sign_up.sale_consignor_time_id = internal_drop_off_time_id
      consignor_sign_up.save
    end

    def create_fake_profile
      profile = Profile.new
      profile.id = @profile_id
      profile.email = "consignor#{@profile_id}@kidscloset.biz"
      profile.email_confirmation = "consignor#{@profile_id}@kidscloset.biz"
      profile.first_name = "Consignor"
      profile.last_name = @profile_id
      profile.phone = ""
      profile.build_user(
        :login => profile.email,
        :password => "password",
        :password_confirmation => "password"
      )
      profile.save!
    end

  end

end