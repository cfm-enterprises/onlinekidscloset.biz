class PayPalOrder < ActiveRecord::Base
	has_many :orders, :dependent => :nullify
	belongs_to :profile
	belongs_to :sale

	def total_amount
		orders.sum(:total_amount)
	end

	def sales_tax
		orders.sum(:sales_tax)
	end

	def sub_total
		orders.sum(:item_price)
	end

	def total_amount_in_cents
		total_amount * 100
	end

	def sub_total_in_cents
		sub_total * 100
	end

	def sales_tax_in_cents
		sales_tax * 100
	end

	def order_description(separator = "; ")
    item_descriptions = []
    for item in orders
      item_descriptions << "#{item.item_name}, #{item.consignor_inventory_id}"
    end
    item_descriptions << "#{orders.count} Item(s) Purchased" 
    return item_descriptions.join(separator)
	end

	def button_description
    return "#{sale.franchise.franchise_name} Purchase - #{orders.count} Item(s) Purchased" 
	end

  def pay_pal_email
    sale.franchise.pay_pal_email
  end


  class << self
		def expired_orders
			PayPalOrder.find(:all, :conditions => ["ordered_at < ? AND purchased_at IS NULL", Time.now - 15 * 60])
		end
	end
end
