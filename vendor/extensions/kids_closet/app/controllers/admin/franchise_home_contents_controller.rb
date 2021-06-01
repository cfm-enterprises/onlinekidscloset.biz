class Admin::FranchiseHomeContentsController < ApplicationController

  def index
    @franchise = Franchise.find(params[:franchise_id])
    if @franchise.franchise_home_content.nil?
    	@franchise_home_content = FranchiseHomeContent.new
    	@franchise_home_content.franchise = @franchise
    	@franchise_home_content.save
    else
	    @franchise_home_content = @franchise.franchise_home_content 
	end
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def update
    @franchise_home_content = FranchiseHomeContent.find(params[:id])

    respond_to do |format|
      if @franchise_home_content.update_attributes(params[:franchise_home_content])
        flash[:notice] = 'Franchise Home Content was successfully updated.'
        format.html { redirect_to :controller => '/admin/franchises', :action => "show", :id => @franchise_home_content.franchise_id }
      else
        format.html { render :action => "new"}
      end
    end
  end
end
