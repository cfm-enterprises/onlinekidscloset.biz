class Order < ActiveRecord::Base
	require 'active_merchant'

	belongs_to :consignor_inventory
	belongs_to :sale
	belongs_to :seller, :class_name => "Profile", :foreign_key => 'seller_id'
	belongs_to :buyer, :class_name => "Profile", :foreign_key => 'buyer_id'
	belongs_to :pay_pal_order
	
	validates_uniqueness_of :consignor_inventory_id, :message => " item is currently in another customers shopping cart and is unavailable."

  class << self
		def the_gateway(franchise = nil)
			ActiveMerchant::Billing::Base.mode = :production
		  paypal_options = {
		    :login => franchise.nil? ? "overlandpark.ks_api1.kidscloset.biz" : franchise.paypal_login,
		    :password => franchise.nil? ? "FT7E9Q7QUJ8NB2SE" : franchise.paypal_password,
		    :signature => franchise.nil? ? "AFcWxV21C7fd0v3bYYYRCpSSRl31AoFsyH.Iozhv0.lun-t9qrg3uXBZ" : franchise.paypal_signature
		  }
	#	  ::STANDARD_GATEWAY = ActiveMerchant::Billing::PaypalGateway.new(paypal_options)
		  ActiveMerchant::Billing::PaypalExpressGateway.new(paypal_options)
		end

		def expired_orders
			Order.find(:all, :conditions => ["ordered_at < ? AND purchased_at IS NULL AND pay_pal_order_id IS NULL", Time.now - 120 * 60])
		end
	end

	def total_amount_in_cents
		total_amount * 100
	end

	def price_in_cents
		item_price * 100
	end

	def sales_tax_in_cents
		sales_tax * 100
	end

end
