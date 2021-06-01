class Admin::KidsEmailsController < ApplicationController
  require 'csv'
  layout 'admin/kids_closet'

  #GET /admin/franchises/:franchise_id/kids_emails
  def index
    @franchise = Franchise.find(params[:franchise_id])
    @kids_emails = @franchise.kids_emails.paginate(:all, :page => params[:page], :order => "draft_mode DESC, sent_at DESC")
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def new
    @kids_email = KidsEmail.new
    @kids_email.franchise_id = params[:franchise_id]
    @kids_email.master_email = false
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def email_volunteers_in_job
    @job = SaleVolunteerTime.find(params[:id])
    @kids_email = KidsEmail.new
    @kids_email.franchise_id = @job.sale.franchise_id
    @kids_email.master_email = false
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def send_email_to_volunteers_in_job
    @job = SaleVolunteerTime.find(params[:id])
    @kids_email = KidsEmail.new(params[:kids_email])
    franchise = Franchise.find(params[:franchise_id])
    for franchise_profile in @job.volunteer_profiles
        profile = franchise_profile.profile
        if profile.is_subscribed && !profile.bad_email
          email = KidsMailer.create_general_mass_email(franchise, nil, profile, @kids_email.subject, @kids_email.html_body, "", "", franchise.franchise_email)
          KidsMailer.deliver(email)                         
        end
    end
    respond_to do |format|
      flash[:notice] = "Email sent to helpers for this job."
      format.html {redirect_to admin_sale_volunteer_time_url(@job)}
    end
  end

  def create
    @kids_email = KidsEmail.new(params[:kids_email])
    if params[:commit] == "Send Test"
      if @kids_email.valid?
        if @kids_email.draft_recipient.not_blank? 
          email = KidsMailer.create_general_mass_email(@kids_email.franchise, @kids_email.draft_recipient, nil, @kids_email.subject, @kids_email.html_body, "", "", @kids_email.franchise.franchise_email)
    	    KidsMailer.deliver(email)			          
          flash[:notice] = "Draft Email Sent to #{@kids_email.draft_recipient}"
        else
          flash[:error] = "Please enter email address to send a draft copy of this message"
        end
      end
      respond_to do |format|
        format.html {render :action => 'new'}
      end
    elsif params[:commit] == "Save Draft"
      @kids_email.draft_mode = true
      if @kids_email.save
        flash[:notice] = "Email Has Been Saved as a Draft"
        KidsEmail.find(params[:draft_id]).destroy if params[:draft_id]
        respond_to do |format|
          format.html {redirect_to admin_franchise_kids_emails_url(@kids_email.franchise)}
        end
      else
        respond_to do |format|
          format.html { render :action => "new" }
        end
      end
    elsif params[:commit] == "Export List"
      csv_string = FasterCSV.generate do |csv|
        csv << ['Email', 'Consignor #', 'Address', 'City', 'State', 'Zip Code', 'First Name', 'Last Name', 'Phone']
        @kids_email.email_array.each do |id|
          profile = Profile.find(id)
          if profile.is_subscribed && !profile.bad_email
            address = profile.addresses.find(:first)
            if address.nil?
              csv << [profile.email, profile.id, '', '', '', '', profile.first_name, profile.last_name, profile.phone ]
            else
              csv << [profile.email, profile.id, address.address_line_1, address.city, address.site_province.province.code, address.postal_code, profile.first_name, profile.last_name, profile.phone ]
            end          
          end          
        end
      end
      send_data csv_string,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=#{@kids_email.recipients}_email_export.csv"    
    else
      @kids_email.sent_at = @kids_email.schedule_email ? @kids_email.send_at : Time.now
      @kids_email.estimated_number_of_emails = @kids_email.number_of_emails
      if @kids_email.save
        KidsEmail.find(params[:draft_id]).destroy if params[:draft_id]
        1.upto(@kids_email.number_of_jobs) { |page| 
          Delayed::Job.enqueue(
            KidsCloset::KidsEmailSender.new(params[:franchise_id], @kids_email.recipients, @kids_email.subject, @kids_email.schedule_email ? "true" : "false", page, "", @kids_email.html_body), 0, @kids_email.schedule_email ? (@kids_email.send_at + (page * 5 * 60)) : (page * 5).minutes.from_now, @kids_email.id
          )
        }
        flash[:notice] = "Email Has Been Scheduled for Sending"
        respond_to do |format|
          format.html {redirect_to admin_franchise_kids_emails_url(@kids_email.franchise)}
        end
      else
        respond_to do |format|
          format.html { render :action => "new" }
        end
      end
    end
  end

  #GET /admin/franchises/edit/:id
  def edit
    @kids_email = KidsEmail.find(params[:id])
    respond_to do |format|
      format.html { render :action => "new" }# edit.html.erb
    end
  end

  def update
    create
  end

  def destroy
    @kids_email = KidsEmail.find(params[:id])
    @kids_email.destroy
    flash[:notice] = "Email has been deleted from the system."
    respond_to do |format|
          format.html {redirect_to admin_franchise_kids_emails_url(@kids_email.franchise)}
    end
  end
end
