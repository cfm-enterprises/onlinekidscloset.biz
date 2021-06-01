class Admin::FranchiseProfilesController < ApplicationController
  before_filter :load_countries_and_provinces, :except => [:remove]
  before_filter :find_franchise_profile, :only => [:edit, :update, :good_email, :bad_email]

  # GET /admin/profiles/new
  def new
    @franchise = Franchise.find(params[:franchise_id])
    @franchise_profile = FranchiseProfile.new
    @franchise_profile.franchise = @franchise
    @profile = Profile.new
    @profile.address_site_country_id = 1
    respond_to do |format|
      format.html # new_member.html.erb
    end
  end

  # POST /admin/franchise/:franchise_id/franchise_profiles
  def create
    @profile = Profile.find_by_email(params[:profile][:email])
    @franchise_profile = FranchiseProfile.new(params[:franchise_profile])
    FranchiseProfile.transaction do
      if @profile.nil?
        @profile = Profile.new(params[:profile])
        @profile = update_profile_for_register_account(@profile)
        @profile.histories.build(:message => "Profile Created by: #{@franchise_profile.franchise.franchise_name} Owner")
        @profile.save!
        @franchise_profile.profile_id = @profile.id
        @franchise_profile.active = (@franchise_profile.consignor || @franchise_profile.volunteer) ? true : false
        @franchise_profile.mailing_list = true if @franchise_profile.mailing_list && !@franchise_profile.active
        @franchise_profile.save!
        send_consignor_email = @franchise_profile.consignor
        send_mailing_list_email = @franchise_profile.mailing_list
        flash[:notice] = 'Profile was successfully created.'
      else
        franchise_profile = FranchiseProfile.find(:first, :conditions => ["profile_id = ? AND franchise_id = ?", @profile.id, @franchise_profile.franchise_id])
        if franchise_profile.nil?
          @franchise_profile.profile_id = @profile.id
          @franchise_profile.active = (@franchise_profile.consignor || @franchise_profile.volunteer) ? true : false
          @franchise_profile.mailing_list = true if @franchise_profile.mailing_list && !@franchise_profile.active
          send_consignor_email = @franchise_profile.consignor
          send_mailing_list_email = @franchise_profile.mailing_list
          @franchise_profile.save!
        else
          send_consignor_email = @franchise_profile.consignor && !franchise_profile.consignor
          send_mailing_list_email = @franchise_profile.mailing_list && !franchise_profile.mailing_list
          franchise_profile.active = (@franchise_profile.consignor || @franchise_profile.volunteer) ? true : false
          franchise_profile.consignor = true if @franchise_profile.consignor
          franchise_profile.volunteer = true if @franchise_profile.volunteer
          franchise_profile.active = (@franchise_profile.consignor || @franchise_profile.volunteer) ? true : false
          franchise_profile.mailing_list = true if @franchise_profile.mailing_list && !franchise_profile.active
          franchise_profile.save!
          send_mailing_list_email = send_mailing_list_email && franchise_profile.mailing_list
          @franchise_profile = franchise_profile
        end
        flash[:notice] = 'Existing Profile added to the franchise.'
      end
      if send_consignor_email
        FranchiseProfile.sign_up_to_consign_active_sale(@franchise_profile)
        email = KidsMailer.create_consignor_confirmation_email(@franchise_profile.franchise, @profile, @franchise_profile.franchise.active_sale_id)
        if KidsMailer.deliver(email)
          @profile.histories.create(:message => "Consignor Thank You email sent")
        end
      end
      if send_mailing_list_email
        body_html = "<p>Thank you for signing up to receive emails from the Kid’s Closet Connection -  <b>#{@franchise_profile.franchise.franchise_name}</b> sale.</p><p>To ensure you receive future emails from Kid’s Closet Connection, please add this email address to your safe sender list.</p>"
        subject = "Kids Closet Connection - Join Mailing List Confirmation"
        email = KidsMailer.create_general_mass_email(nil, nil, @profile, subject, body_html, "Remove me from this mailing list.", "http://www.kidscloset.biz/home/unsubscribe_franchise_profile/#{@franchise_profile.id}", "donotreply@kidscloset.biz")	    			
        if KidsMailer.deliver(email)
          @profile.histories.create(:message => "Mailing List Confirmation email sent")
        end            
      end              
      respond_to do |format|
        if @franchise_profile.consignor
          format.html { redirect_to(consignors_admin_franchise_url(@franchise_profile.franchise)) }
        elsif @franchise_profile.mailing_list
          format.html { redirect_to(mailing_list_members_admin_franchise_url(@franchise_profile.franchise)) }
        else
          format.html { redirect_to(volunteers_admin_franchise_url(@franchise_profile.franchise)) }
        end
      end
    end
      
  rescue ActiveRecord::RecordInvalid => e
    @franchise = @franchise_profile.franchise
    @profile.address_site_province_id = @profile.address_site_province_id.to_i
    @profile = handle_profile_errors(@profile)
    respond_to do |format|
      format.html { render :action => "new" }
    end
  end

  # GET /admin/franchises/:franchise_id/franchise_profile/:id
  def edit
    @franchise = @franchise_profile.franchise
    @profile = @franchise_profile.profile
    address = @profile.addresses.find(:first, :conditions => ["label = ?", "Main Address"])
    unless address.nil?
      @profile.address_address_line_1 = address.address_line_1
      @profile.address_address_line_2 = address.address_line_2
      @profile.address_city = address.city
      @profile.address_site_province_id = address.site_province_id
      @profile.address_postal_code = address.postal_code
    end
    @profile.address_site_country_id = 1
    respond_to do |format|
      format.html # new_member.html.erb
    end
  end

  # PUT /admin/franchises/:franchise_id/franchise_profile/:id
  def update
    @profile = @franchise_profile.profile
    @profile.attributes = params[:profile]
    @profile.histories.build(:message => "Profile Edited by: #{@franchise_profile.franchise.franchise_name} Owner")
    send_consignor_email = !@franchise_profile.consignor
    send_mailing_list_email = !@franchise_profile.mailing_list
    @franchise_profile.attributes = params[:franchise_profile]
    FranchiseProfile.transaction do
      @profile = update_profile_for_register_account(@profile)
      @franchise_profile.active = (@franchise_profile.consignor || @franchise_profile.volunteer) ? true : false
      @franchise_profile.mailing_list = true if @franchise_profile.mailing_list && !@franchise_profile.active
      @profile.save!
      @franchise_profile.save!
      if send_consignor_email && @franchise_profile.consignor
        FranchiseProfile.sign_up_to_consign_active_sale(@franchise_profile)
        body_html = "<p>Thank you for signing up to consign at the <b>#{@franchise_profile.franchise.franchise_name}</b> sale.</p>
            <p>Please visit your <a href=\"http://www.kidscloset.biz/consignors\">Control Panel</a> where you can sign up for a drop off times, help for a sale, create and print your tags or select another event to consign at.</p>"
        subject = "Kids Closet Connection - Consignor Sign Up Confirmation"
        email = KidsMailer.create_general_mass_email(nil, nil, @profile, subject, body_html, "Cancel Consignment with Kids Closet Connection.", "http://www.kidscloset.biz/consignors", "donotreply@kidscloset.biz")	    			
        if KidsMailer.deliver(email)
          @profile.histories.create(:message => "Consignor Thank You email sent")
        end
      end
      if send_mailing_list_email && @franchise_profile.mailing_list
        body_html = "<p>Thank you for signing up to receive emails from the Kid’s Closet Connection -  <b>#{@franchise_profile.franchise.franchise_name}</b> sale.</p><p>To ensure you receive future emails from Kid’s Closet Connection, please add this email address to your safe sender list.</p>"
        subject = "Kids Closet Connection - Join Mailing List Confirmation"
        email = KidsMailer.create_general_mass_email(nil, nil, @profile, subject, body_html, "Remove me from this mailing list.", "http://www.kidscloset.biz/home/unsubscribe_franchise_profile/#{@franchise_profile.id}", "donotreply@kidscloset.biz")	    			
        if KidsMailer.deliver(email)
          @profile.histories.create(:message => "Mailing List Confirmation email sent")
        end            
      end
      if @franchise_profile.is_current_volunteer? && @franchise_profile.franchise.active_sale.start_date > Date.today
        unless @franchise_profile.consignor && @franchise_profile.items_coming > 0
          volunteer_jobs = SaleVolunteerSignUp.volunteer_sign_ups_for_sale(@franchise_profile.franchise.active_sale_id, @franchise_profile.id)
          for job in volunteer_jobs
            job.destroy
          end
        end
      end
    end
    flash[:notice] = "Franchise Profile successfully updated"
    respond_to do |format|
      flash[:notice] = 'Profile was successfully updated.'
      format.html {redirect_to (session[:return_url])}
    end

  rescue ActiveRecord::RecordInvalid => e
    @franchise = @franchise_profile.franchise
    @profile.address_site_province_id = @profile.address_site_province_id.to_i
    @franchise_profile.valid?
    respond_to do |format|
      format.html { render :action => "edit" }
    end
  end

  # POST /admin/franchise/:franchise_id/franchise_profile
  def remove
    franchise_profile = FranchiseProfile.find(params[:id])
    franchise_profile.active = false
    current_sale = Sale.current_active_sale(franchise_profile.franchise_id)
    if !current_sale.nil? && franchise_profile.consignor && current_sale.start_date > Date.today
      consignor_sign_up = SaleConsignorSignUp.consignor_sign_up_for_sale(current_sale.id, franchise_profile.id)
      consignor_sign_up.destroy unless consignor_sign_up.nil?
    end
    franchise_profile.consignor = false
    if !current_sale.nil? && franchise_profile.volunteer && current_sale.start_date > Date.today
      volunteer_sign_ups = SaleVolunteerSignUp.volunteer_sign_ups_for_sale(current_sale.id, franchise_profile.id)
  	  volunteer_sign_ups.each do |sign_up|
  		sign_up.destroy
  	  end
    end
    franchise_profile.volunteer = false
    franchise_profile.mailing_list = false
    if franchise_profile.save
      flash[:notice] = "Profile removed from franchise list."
    else
      flash[:error] = "We could not remove this profile from your franchise list"
    end
    redirect_to (session[:return_url])
  end

  def good_email
    respond_to do |format|
      @franchise_profile.profile.bad_email = false
      if @franchise_profile.profile.save
        @franchise_profile.profile.histories.create(:message => "Email Verified as Good Email")
        flash[:notice] = 'Profile email was successfully reinstated.'
      else
        flash[:error] = 'The selected profile could not be updated.'
      end
      format.html {redirect_to (session[:return_url])}
    end
  end

  def bad_email
    respond_to do |format|
      @franchise_profile.profile.bad_email = true
      if @franchise_profile.profile.save
        @franchise_profile.profile.histories.create(:message => "Email Marked as Bad Email")
        flash[:notice] = 'Profile email was marked as a bad email.'
      else
        flash[:error] = 'The selected profile could not be updated.'
      end
      format.html {redirect_to (session[:return_url])}
    end
  end
      
  private
    def update_profile_for_register_account(profile)
      if profile.new_record?
        profile.is_subscribed = true
      else
        if profile.user.not_nil?
          profile.user.attributes = params[:user] if params[:user]
        end        
      end
      unless params[:profile][:address_postal_code].empty_or_nil?
        unless profile.new_record?
          address = profile.addresses.find(:first, :conditions => ["label = ?", "Main Address"])
          address.destroy unless address.nil?
        end
        profile.address_label = params[:profile][:address_label].empty_or_nil? ? "Main Address" : params[:profile][:address_label]
        profile.address_first_name = params[:profile][:address_first_name].empty_or_nil? ? profile.first_name : params[:profile][:address_first_name]
        profile.address_last_name = params[:profile][:address_last_name].empty_or_nil? ? profile.last_name : params[:profile][:address_last_name]
        profile.addresses.build(
          :label => profile.address_label,
          :first_name => profile.address_first_name,
          :last_name => profile.address_last_name,
          :address_line_1 => params[:profile][:address_address_line_1],
          :address_line_2 => params[:profile][:address_address_line_2],
          :city => params[:profile][:address_city],
          :site_country_id => params[:profile][:address_site_country_id],
          :site_province_id => params[:profile][:address_site_province_id],
          :postal_code => params[:profile][:address_postal_code]
        )
      end
      profile
    end

    def handle_profile_errors(profile)
      unless profile.user.nil?
        profile.user.errors.each do |attribute, message|
          if params[:profile][attribute.to_sym].not_nil?
            profile.errors.add(attribute, message)
          end
        end
      end
      if profile.addresses.length > 0
        # assume only one
        address = profile.addresses.first
        unless address.valid?
          errors = []
          profile.errors.each do |attribute, message|
            errors << [attribute, message] unless attribute == "addresses"
          end
          profile.errors.clear
          for error in errors
            profile.errors.add(error[0], error[1])
          end
          address.errors.each do |attribute, message|
            address_attribute = "address_#{attribute.to_s}".to_sym
            if params[:profile][address_attribute].not_nil?
              profile.errors.add(address_attribute, message)
            end
          end
        end
      end
      profile
    end


    def load_countries_and_provinces
      @site_countries = SiteCountry.all
      @site_provinces = SiteProvince.active.find(:all, :conditions => ['site_country_id in (?)', @site_countries.map(&:id)])
    end

    def find_franchise_profile
      @franchise_profile = FranchiseProfile.find(params[:id])
    end

end
