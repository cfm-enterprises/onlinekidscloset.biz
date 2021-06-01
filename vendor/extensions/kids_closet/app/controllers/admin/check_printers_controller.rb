class Admin::CheckPrintersController < ApplicationController

  def new
    @check_printer = CheckPrinter.new
    @sale = Sale.find(params[:sale_id])
    @check_printer.owner_name = current_user.profile.full_name
    @check_printer.company_name = @sale.franchise.franchise_name
    @check_printer.address = @sale.sale_address
    @check_printer.address_2 = "#{@sale.franchise.sale_city}, #{@sale.franchise.province.code} #{@sale.sale_zip_code}"
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def create
    @check_printer = CheckPrinter.new(params[:check_printer])
    @sale = Sale.find(params[:sale_id])
    @consignors = @sale.consignor_profiles.find(:all, :order => "profiles.id")
    respond_to do |format|
      if @check_printer.save
        @check_number = @check_printer.starting_check_number
        format.html {render  :template => 'admin/check_printers/check_report.pdf.erb',
                            :pdf => "kcc_checks.pdf",
                            :layout => 'tags.html',
                            :page_size => 'Letter',
                            :margin => {
                              :top                => 5,
                              :bottom             => 0,
                              :left               => 15,
                              :right              => 25}                            
                    }               
      else
        format.html {render :action => 'new'}
      end
    end
  end
  
  def check_report
    
  end
end
