class Admin::KidsMasterEmailsController < ApplicationController
  require 'csv'
  layout 'admin/kids_closet'

  def index
    @kids_emails = KidsEmail.master_emails.paginate(:all, :page => params[:page], :order => "draft_mode DESC, sent_at DESC")
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def new
    @kids_email = KidsEmail.new
    @kids_email.master_email = true
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def create
    @kids_email = KidsEmail.new(params[:kids_email])
    if params[:commit] == "Send Test"
      if @kids_email.valid?
        if @kids_email.draft_recipient.not_blank? 
          email = KidsMailer.create_general_mass_email(nil, @kids_email.draft_recipient, nil, @kids_email.subject, @kids_email.html_body, "", "", "ssmitka@kidscloset.biz")
    	    KidsMailer.deliver(email)         
          flash[:notice] = "Draft Email Sent to #{@kids_email.draft_recipient}"
        else
          flash[:error] = "Please enter email address to send a draft copy of this message"
        end
      end
      respond_to do |format|
        format.html {render :action => 'new'}
      end
    elsif params[:commit] == "Export List"
      Delayed::Job.enqueue(
        KidsCloset::KidsMasterEmailList.new(@kids_email.recipients, current_user.profile.email), 0, 2.seconds.from_now
      )
      flash[:notice] = "You will receive an email with a link to the export file shortly."
      respond_to do |format|
        format.html {redirect_to admin_kids_master_emails_url}
      end
    elsif params[:commit] == "Save Draft"
      @kids_email.draft_mode = true
      if @kids_email.save
        flash[:notice] = "Email Has Been Saved as a Draft"
        KidsEmail.find(params[:draft_id]).destroy if params[:draft_id]
        respond_to do |format|
          format.html {redirect_to admin_kids_master_emails_url}
        end
      end
    else
      @kids_email.sent_at = @kids_email.schedule_email ? @kids_email.send_at : Time.now
      @kids_email.estimated_number_of_emails = @kids_email.number_of_emails
      if @kids_email.save
        KidsEmail.find(params[:draft_id]).destroy if params[:draft_id]
        1.upto(@kids_email.number_of_jobs) { |page| 
          Delayed::Job.enqueue(
            KidsCloset::KidsMasterEmailSender.new(@kids_email.recipients, @kids_email.subject, @kids_email.schedule_email ? "true" : "false", page, current_user.profile.email, "", @kids_email.html_body), 0, @kids_email.schedule_email ? (@kids_email.send_at + (page * 5 * 60)) : (page * 5).minutes.from_now, @kids_email.id
          )
        }
        flash[:notice] = "Email Successfully Scheduled for Delivery"
        respond_to do |format|
          format.html {redirect_to admin_kids_master_emails_url}
        end
      else
        respond_to do |format|
          format.html {render :action => 'new'}
        end
      end
    end
  end

  def edit
    @kids_email = KidsEmail.find(params[:id])
    respond_to do |format|
      format.html  # edit.html.erb
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
        format.html {redirect_to admin_kids_master_emails_url}
    end
  end
end
