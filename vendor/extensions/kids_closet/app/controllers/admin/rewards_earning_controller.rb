class Admin::RewardsEarningController < ApplicationController
  # DELETE /admin/sale/:sale_id/rewards_earning
  def destroy
    @rewards_earning = RewardsEarning.find(params[:id])
    @rewards_earning.destroy if @rewards_earning.sale_id = params[:sale_id]

    respond_to do |format|
      flash[:warning] = "Rewards Application was successfully deleted."
        format.html { redirect_to rewards_history_admin_sale_url(@rewards_earning.sale)}
    end
  end
end
