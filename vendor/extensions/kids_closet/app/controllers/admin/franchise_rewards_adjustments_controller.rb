class Admin::FranchiseRewardsAdjustmentsController < ApplicationController
  #Get /admin/franchise/:franchise_id/franchise_rewards_adjustments
  def index
    @franchise = Franchise.find(params[:franchise_id])
    @franchise_rewards_adjustments = @franchise.franchise_rewards_adjustments.paginate(:all, :page => params[:page])
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def new
    @franchise_rewards_adjustment = FranchiseRewardsAdjustment.new
    @franchise_rewards_adjustment.franchise = Franchise.find(params[:franchise_id])    
  end
  
  def edit
    @franchise_rewards_adjustment = FranchiseRewardsAdjustment.find(params[:id])
    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  # POST /admin/franchise/:franchise_id/franchise_rewards_adjustment/
  def create
    @franchise_rewards_adjustment = FranchiseRewardsAdjustment.new(params[:franchise_rewards_adjustment])
    respond_to do |format|
      if @franchise_rewards_adjustment.save
        flash[:notice] = "Franchise Rewards Adjustment Created Successfully"
        format.html { redirect_to admin_franchise_franchise_rewards_adjustments_url(@franchise_rewards_adjustment.franchise)}
      else
        format.html { render :action => "new"}
      end
    end
  end

  # PUT /admin/franchsie/:franchise_id/franchise_rewards_adjustment/:id
  def update
    @franchise_rewards_adjustment = FranchiseRewardsAdjustment.find(params[:id])

    respond_to do |format|
      if @franchise_rewards_adjustment.update_attributes(params[:franchise_rewards_adjustment])
        flash[:notice] = 'Franchise Rewards Adjustment was successfully updated.'
        format.html { redirect_to(admin_franchise_franchise_rewards_adjustments_url(@franchise_rewards_adjustment.franchise)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /admin/franchises/:id/franchise_rewards_adjustment/:id
  def destroy
    @franchise_rewards_adjustment = FranchiseRewardsAdjustment.find(params[:id])
    @franchise_rewards_adjustment.destroy

    respond_to do |format|
      flash[:warning] = "Franchise Rewards Adjustment was successfully deleted."
      format.html { redirect_to admin_franchise_franchise_rewards_adjustments_url(@franchise_rewards_adjustment.franchise)}
    end
  end

end
