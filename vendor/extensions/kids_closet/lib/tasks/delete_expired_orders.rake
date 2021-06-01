namespace :kids_closet do
  desc "delete orders that have not been completed in 60 minutes"
  task :delete_expired_orders => :environment do
    Site.current_site_id = 1
    ENV['TZ'] = 'UTC'
    for order in Order.expired_orders
    	order.destroy
    end
#    for order in PayPalOrder.expired_orders
#    	order.destroy
#    end
  end
end
