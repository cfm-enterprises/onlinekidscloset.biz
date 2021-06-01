module KidsCloset
  module HomeControllerMixin

    # TEST GETTING RID OF ADDRESSES ERROR

    # GET /home/become_member/:id
    def become_member
      franchise_profile = FranchiseProfile.find(:first, :conditions => ["profile_id = ? AND franchise_id = ?", current_profile_id, params[:id]])
      if franchise_profile.nil?
        franchise_profile = FranchiseProfile.new
        franchise_profile.profile_id = current_profile_id
        franchise_profile.franchise_id = params[:id]
      end
      if franchise_profile.profile_id == -1
        flash[:error] = "We could not sign you up to the mailing list.  Please email us the exact steps you took to sign up so that we can prevent this from happening again."
        redirect_to '/find_sale'
      elsif franchise_profile.consignor || franchise_profile.volunteer
        flash[:warning] = "You are already consigning or helping for this sale.  To prevent duplicate emails, you were not added to this mailing list."
        redirect_to '/find_sale'
      elsif franchise_profile.mailing_list
        flash[:notice] = "You were already signed up for the mailing list for the #{franchise_profile.franchise.franchise_name} sale."          
        redirect_to "/find_sale"
      else        
        franchise_profile.mailing_list = true
        if save_objeck(franchise_profile)
          body_html = "<p>Thank you for signing up to receive emails from the Kid’s Closet Connection -  <b>#{franchise_profile.franchise.franchise_name}</b> sale.</p><p>To ensure you receive future emails from Kid’s Closet Connection, please add this email address to your safe sender list.</p>"
          subject = "Kids Closet Connection - Join Mailing List Confirmation"
          email = KidsMailer.create_general_mass_email(franchise_profile.franchise, nil, current_profile, subject, body_html, "Remove me from this mailing list.", "http://www.kidscloset.biz/home/unsubscribe_franchise_profile/#{franchise_profile.id}", "donotreply@kidscloset.biz")	    			
          if KidsMailer.deliver(email)
            franchise_profile.profile.histories.create(:message => "Mailing List Confirmation email sent")
          end            
          subject = "New Newsletter Member for your #{franchise_profile.franchise.franchise_name} sale!"
          email = KidsMailer.create_franchise_owner_notification_email(franchise_profile, subject)
          KidsMailer.deliver(email)
          flash[:notice] = "You are signed up for the mailing list for the #{franchise_profile.franchise.franchise_name} sale."          
          redirect_to "/sale/mailing_list_thank_you?sale_id=#{params[:id]}"
        else
          flash[:error] = "We could not sign you up for the mailing list."
          redirect_to '/find_sale'
        end
      end
    end
    
    # GET /home/become_member/:id
    def become_buyer
      franchise_profile = FranchiseProfile.find(:first, :conditions => ["profile_id = ? AND franchise_id = ?", current_profile_id, params[:id]])
      if franchise_profile.nil?
        franchise_profile = FranchiseProfile.new
        franchise_profile.profile_id = current_profile_id
        franchise_profile.franchise_id = params[:id]
      end
      path = if session[:previous_page].empty_or_nil?
        Lockdown::System.fetch :successful_login_path
      else
        session[:previous_page]
      end
      if franchise_profile.profile_id == -1
        redirect_to path
      elsif franchise_profile.consignor || franchise_profile.volunteer
        redirect_to path
      else        
        franchise_profile.mailing_list = true
        if save_objeck(franchise_profile)
          redirect_to path
        else
          redirect_to path
        end
      end
    end

    #GET /home/unsubscribe_franchise_profile/:id
    def unsubscribe_franchise_profile
      franchise_profile = FranchiseProfile.find(params[:id])
      franchise_profile.mailing_list = false
      if save_objeck(franchise_profile)
        set_session_profile(franchise_profile.profile)
        flash[:notice] = "You were successfully removed from the #{franchise_profile.franchise.franchise_name} mailing list"
        redirect_to '/unsubscribe_confirmation'
      else
        flash[:error] = "We could not remove you from the mailing list."
        redirect_to '/'
      end
    end
    
    #GET /home/unsubscribe_profile/:id
    def unsubscribe_profile
      profile = Profile.find(params[:id])
      profile.is_subscribed = false
      set_session_profile(profile)
      if save_objeck(profile)
        flash[:notice] = "You have been unsubscribed from receiving emails from Kids Closet Connection"
        redirect_to '/unsubscribe_confirmation'
      else
        flash[:error] = "We could not remove you from the Kids Closet Connection mailing list"
        redirect_to '/profile'
      end        
    end
    
    def self.included(base)
      base.class_eval do
        include InstanceMethods
      end
    end


    def kids_login
      set_session_user(User.kids_authenticate(params[:user][:login], params[:user][:password]))
      if logged_in?
        user = current_user
        user.last_login_at = DateTime.now
        user.save_without_auditing
        flash[:notice] = "Logged in successfully"
        path = if session[:previous_page].empty_or_nil?
          if params[:success_url].empty_or_nil? || params[:success_url].first != "/"
            Lockdown::System.fetch :successful_login_path
          else
            params[:success_url] || "/"
          end
        else
          session[:previous_page]
        end
        redirect_to path
      else
        flash[:error] = 'Login unsuccessful. Please try again.'
        redirect_to login_path
      end
    end

    module InstanceMethods
      require "uuidtools"

      # will create profile with an user account
      def kids_register_account
        profile = Profile.find_by_email(params[:profile][:email]) unless params[:profile][:email].empty_or_nil?
        if profile && profile.has_account?
          flash[:error] = "Email already has a user name and password. Please login first or adjust the information on the form."
          profile = Profile.new(params[:profile])
          show_failure(profile) and return
        end
        if profile
          profile.attributes = params[:profile]
        else  
          profile = Profile.new(params[:profile])
        end
        profile = update_profile_for_register_account(profile)
        if profile.first_name == profile.last_name
          redirect_to '/sale/consignor_thank_you?sale_id=7'  
        else
          if save_objeck(profile)
            body_html = "<p>Thanks for registering your account with Kids Closet Connection.  
                To ensure you receive future emails from Kid’s Closet Connection, please add this email address to your Safe Sender List or Contact List.<p>
                <p>Your consignor number is #{profile.id}.<br>Your user name is #{params[:profile][:login]}.<br>Your password is #{params[:profile][:password]}.<br> 
                Please record and print this information for your records.</p>  
                <p>To access your account, logon to <a href=\"http://www.kidscloset.biz\">Kids Closet Connection</a>, click on <a href=\"http://www.kidscloset.biz/login\">Account Login</a> and enter your username and password.   
                This will take you to your Control Panel where you can sign up for a drop off times, help for a sale, create and print your tags or select another event to consign at.</p>"
            subject = "Kids Closet Connection - Registration Confirmation"
            email = KidsMailer.create_general_mass_email(nil, nil, profile, subject, body_html, "", "", "donotreply@kidscloset.biz")	    			
            if KidsMailer.deliver(email)
              profile.histories.create(:message => "Register Thank You email sent")
            end
            show_success(profile.class.to_s)
            set_session_user(profile.user)
          else
            profile = handle_profile_errors(profile)
            show_failure(profile)
          end
        end
      end

      #creates an account for buying, returns to online sale
      def kids_register_buyer_account
        profile = Profile.find_by_email(params[:profile][:email]) unless params[:profile][:email].empty_or_nil?
        if profile && profile.has_account?
          flash[:error] = "Email already has a user name and password. Please login first or adjust the information on the form."
          profile = Profile.new(params[:profile])
          show_failure(profile) and return
        end
        if profile
          profile.attributes = params[:profile]
        else  
          profile = Profile.new(params[:profile])
        end
        profile = update_profile_for_register_account(profile)
        if profile.first_name == profile.last_name
          redirect_to '/sale/consignor_thank_you?sale_id=7'  
        else
          if save_objeck(profile)
            body_html = "<p>Thanks for registering your account with Kids Closet Connection.  
                To ensure you receive future emails from Kid’s Closet Connection, please add this email address to your Safe Sender List or Contact List.<p>
                <p>Your user name is #{params[:profile][:email]}.<br>Your password is #{params[:profile][:password]}.<br> 
                Please record and print this information for your records.</p>  
                <p>To access your account, logon to <a href=\"http://www.kidscloset.biz\">Kids Closet Connection</a>, click on <a href=\"http://www.kidscloset.biz/login\">Account Login</a> and enter your username and password.   
                Once logged in, you can purchase items online from any online sale in your area.</p>"
            subject = "Kids Closet Connection - Registration Confirmation"
            email = KidsMailer.create_general_mass_email(nil, nil, profile, subject, body_html, "", "", "donotreply@kidscloset.biz")            
            if KidsMailer.deliver(email)
              profile.histories.create(:message => "Buyer Register Thank You email sent")
            end
            show_success(profile.class.to_s)
            set_session_user(profile.user)
          else
            profile = handle_profile_errors(profile)
            show_failure(profile)
          end
        end
      end

      def kids_request_password
        profile = Profile.find_by_email(params[:email])
        if profile.nil?
          flash[:error] = "Account not found."
          show_failure(nil)
        else
          if profile.user.nil?
            password = DateTime.now.to_s
            profile.build_user(
              :login => profile.email,
              :password => password,
              :password_confirmation => password
            )
          end
          profile.user.reset_token = UUIDTools::UUID.random_create.to_s
          profile.user.reset_requested_at = DateTime.now
          if profile.user.save
            html_body = "We received a request password request.<br>Your user name is <b>#{profile.user.login}</b>.<br><a href=\"#{request.protocol}#{request.host}/new-password?reset_token=#{profile.user.reset_token}\">Click here</a> to reset your password."
            subject = "Kids Closet Connection - Forgot Password"
            email = KidsMailer.create_general_mass_email(nil, nil, profile, subject, html_body, "", "", "donotreply@kidscloset.biz")	    			
            if KidsMailer.deliver(email)
              profile.histories.create(:message => "Request password email sent")
            end

            flash[:notice] = "Thank you. You will receive an e-mail shortly with a link to create a new password."
            show_success
          else # just in case
            flash[:error] = "Internal Error!"
            show_failure(nil)
          end
        end
      end

      # will lookup email then create a profile (without a user) if not found
      def kids_marketing_sign_up
        if params[:profile][:email].empty_or_nil?
          flash[:error] = "Email can't be blank."
          show_failure(nil) and return
        end

        if logged_in? && current_profile.email != params[:profile][:email]
          flash[:error] = "Email entered does not match the email in your account."
          show_failure(nil) and return
        end
        profile = Profile.find_by_email(params[:profile][:email])

        if profile && profile.has_account? && !logged_in?
          flash[:error] = "Email already registered. Please login first or adjust the information on the form."
          show_failure(nil) and return
        end

        profile ||= Profile.new(params[:profile])
        profile = update_profile_for_marketing_sign_up(profile)
        if save_objeck(profile)
          set_session_profile(profile)
          show_success(profile.class.to_s)
        else
          show_failure(profile)
        end
      end

      private

      def update_profile_for_register_account(profile)
        profile.build_user(
          :login => params[:profile][:login] || profile.email,
          :password => params[:profile][:password],
          :password_confirmation => params[:profile][:password_confirmation]
        )
        profile.acquisition_source = "Site Registration"
        if params[:profile][:address_postal_code]
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
        profile.user.errors.each do |attribute, message|
          if params[:profile][attribute.to_sym].not_nil?
            profile.errors.add(attribute, message)
          end
        end
        if profile.addresses.length > 0
          # assume only one
          address = profile.addresses.first
          unless address.valid?
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

      def update_profile_for_marketing_sign_up(profile)
        profile.is_subscribed = true

        if profile.new_record?
          profile.acquisition_source = "Website Newsletter"
          profile.first_name = profile.email unless params[:profile][:first_name]
          profile.last_name = "N/A" unless params[:profile][:last_name]
          profile.email_confirmation = profile.email
        else
          update_attributes(profile, profile.class.to_s)
        end
        profile
      end

    end    

    def sale_flyer
      @sale = Sale.current_active_sale(params[:id])      
      respond_to do |format|
        format.html {render :layout => 'flyer'}# print_new_tags.html.erb
        format.pdf {render  :template => 'home/sale_flyer.pdf.erb',
                            :pdf => "sale_flyer.pdf",
                            :layout => 'flyer.html',
                            :page_size => 'Letter',
                            :margin => {
                              :top                => 0,
                              :bottom             => 0,
                              :left               => 0,
                              :right              => 0}
                    }
      end
    end
  end
end
