class Admin::FranchiseOwnerProfilesController < ApplicationController
  before_filter :load_users, :except => [:destroy]

  #GET /admin/franchise/:franchise_id/franchise_owner_profiles/new/
  def new
    @franchise_owner_profile = FranchiseOwnerProfile.new
    @franchise_owner_profile.franchise_id = params[:franchise_id]
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /admin/franchise/:franchise_id/franchise_owner_profile/
  def create
    @franchise_owner_profile = FranchiseOwnerProfile.new(params[:franchise_owner_profile])

    respond_to do |format|
      if @franchise_owner_profile.save
        flash[:notice] = 'Franchise Owner was successfully created.'
        format.html { redirect_to :controller => '/admin/franchises', :action => "show", :id => @franchise_owner_profile.franchise_id }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # DELETE /admin/franchise_owner_profile/:id
  def destroy
    @franchise_owner_profile = FranchiseOwnerProfile.find(:first, :conditions => ["franchise_id = ? AND profile_id = ?", params[:franchise_id], params[:id]])
    @franchise_owner_profile.destroy

    respond_to do |format|
      flash[:warning] = "Franchise Owner was successfully deleted."
      format.html { redirect_to :controller => '/admin/franchises', :action => "show", :id => params[:franchise_id]  }
    end
  end
  

  
  private

  def load_users
    current_owners = FranchiseOwnerProfile.scoped_by_franchise_id(params[:franchise_id])
    franchise_owner_user_group = UserGroup.find_by_name('Franchise Owners')
    current_franchise_owners = franchise_owner_user_group.all_users
    @available_owners = Profile.find(:all, :conditions => ['id not in (?) AND id in (?)', current_owners.empty? ? 0 : current_owners.map(&:profile_id), current_franchise_owners.map(&:profile_id)])
  end
end
