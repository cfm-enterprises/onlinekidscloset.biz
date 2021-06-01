class Admin::PayPalOrdersController < ApplicationController
  #GET /admin/pay_pal_orders
  # DELETE /admin/pay_pal_orders/comfirm_order/:id
  def comfirm_order
    order = PayPalOrder.find(params[:id])
    if order.purchased_at.nil?
      Order.transaction do
        order.purchased_at = Time.now
        order.save!
        for item_ordered in order.orders
          item_ordered.purchased_at = Time.now
          item_ordered.save!
          item = item_ordered.consignor_inventory
          item.sale_id = item_ordered.sale_id
          item.discounted_at_sale = 0
          item.sale_price = item_ordered.item_price
          item.tax_collected = item_ordered.sales_tax
          item.total_price = item_ordered.total_amount
          item.sale_date = Date.today
          item.status = true
          item.sold_online = true
          item.save!
          order.profile.histories.create(:message => "Purchase for Item Number #{item.id} Completed")            
        end
        email = KidsMailer.create_purchase_confirmation_email(order)
        KidsMailer.deliver(email)
        for item_ordered in order.orders
          email = KidsMailer.create_sale_notification_email(item_ordered)
          KidsMailer.deliver(email)
          item_ordered.seller.histories.create(:message => "Sell for Item Number #{item_ordered.consignor_inventory_id} Completed")
        end
        email = KidsMailer.create_owner_purchase_notification(order)
        KidsMailer.deliver(email)
      end
      flash[:notice] = "Payment was successfuly comfirmed"
    else
      flash[:warning] = "The order was already comfirmed"
    end
    respond_to do |format|
      format.html { redirect_to(expired_pay_pal_orders_admin_sale_url(order.sale)) }
    end
    rescue ActiveRecord::RecordInvalid => e
      flash[:warning] = "Transaction completed but there was a system error."
      respond_to do |format|
        format.html { redirect_to(expired_pay_pal_orders_admin_sale_url(order.sale)) }
      end
  end

  # DELETE /admin/pay_pal_orders/cancel_order/:id
  def cancel_order
    order = PayPalOrder.find(params[:id])
    if order.purchased_at.nil? 
      order.destroy
      flash[:notice] = "The order has been cancelled."
    else
      flash[:error] = "This order was already completed and can not be cancelled."
    end
    respond_to do |format|
      format.html { redirect_to(expired_pay_pal_orders_admin_sale_url(order.sale)) }
    end
  end
end
