module KidsCloset
  module ProfileMixin

    def self.included(base)

      base.class_eval do
        has_many :franchise_profiles, :include => :franchise, :order => "franchises.franchise_name", :dependent => :destroy
        has_many :franchise_owner_profiles, :include => :franchise, :order => "franchises.franchise_name", :dependent => :destroy
        has_many :items, :class_name => "ConsignorInventory", :order => "id DESC"
        has_many :sold_items, :class_name => "ConsignorInventory", :conditions => ["status = ?", 1], :order => "sale_date DESC, item_description"
        has_many :unsold_items, :class_name => "ConsignorInventory", :conditions => ["status = ? AND (donate_date = ? || donate_date IS NULL)", false, ''], :order => "id DESC"
        has_many :items_coming_to_sale, :class_name => "ConsignorInventory", :conditions => ["bring_to_sale = ? AND status = ?", true, false], :order => "id DESC"
        has_many :active_items, :class_name => "ConsignorInventory", :conditions => ["status = ? AND (donate_date = ? || donate_date IS NULL) AND bring_to_sale = ?", false, '', true], :order => "id DESC"
        has_many :inactive_items, :class_name => "ConsignorInventory", :conditions => ["status = ? AND (donate_date = ? || donate_date IS NULL) AND bring_to_sale = ?", false, '', false], :order => "id DESC"
        has_many :donated_items, :class_name => "ConsignorInventory", :conditions => ["status = ? AND donate_date IS NOT NULL", 0], :order => "donate_date DESC, item_description"
        has_many :featured_items, :class_name => "ConsignorInventory", :conditions => ["status = ? AND (donate_date = ? || donate_date IS NULL) AND bring_to_sale = ? AND featured_item = ?", false, '', true, true], :order => "id DESC"
        has_many :rewards_profiles, :order => "rewards_number", :dependent => :nullify
        has_many :rewards_earnings, :through => :rewards_profiles, :order => "created_at ASC"
        has_many :franchise_rewards_adjustments, :through => :rewards_profiles, :order => "created_at ASC"
        has_many :orders, :foreign_key => 'buyer_id', :conditions => "purchased_at IS NOT NULL"
        has_many :pending_orders, :class_name => "Order", :foreign_key => 'buyer_id', :conditions => ["purchased_at IS NULL"]
        has_many :sells, :class_name => "Order", :foreign_key => 'seller_id', :conditions => ["purchased_at IS NOT NULL"], :order => "created_at DESC"
        has_many :pay_pal_orders

#        validates_presence_of :phone
        validates_presence_of :sort_column 

        before_validation :assign_sort_group

        attr_accessible :promo_code
        
        def self.sort_groups
          ["A", "B", "C", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
        end

        def self.mass_assign_sort_groups
          for profile in Profile.find(:all, :conditions => "sort_column IS NULL")
            profile.sort_column = self.sort_groups.choice
            profile.save_with_validation(false)
          end
        end

        def legal_name
          "#{self.last_name}, #{self.first_name}"
        end

        def pending_pay_pal_orders
          pay_pal_orders.find(:all, :conditions => ["purchased_at IS NULL"], :order => "id DESC")          
        end

        protected

        def assign_sort_group
          self.sort_column = Profile.sort_groups.choice if self.sort_column.nil?
        end
      end
    end

    def franchises_consigning
      rvalue = []
      for franchise_profile in franchise_profiles
        rvalue << franchise_profile.franchise_id if franchise_profile.is_current_consignor?
      end
      rvalue
    end
    
    def primary_rewards_profile
      rewards_profiles.find(:first, :conditions => ["primary_card = ?", true])
    end

    def items_coming
      items_coming_to_sale.count
    end

    def item_search(search_term)
      return items.find(:all, :conditions => ["id LIKE (?) OR size LIKE lower(?) OR item_description LIKE lower(?) OR price LIKE (?)", "%#{search_term}%", "%#{search_term}%", "%#{search_term}%", "%#{search_term}%"])
    end

    def featured_item_search(search_term, category = nil, sub_category = nil, size = nil)
      like_conditions = [
        "item_description LIKE ?",
        "item_description LIKE ?",
        "item_description LIKE ?",
        "additional_information LIKE (?)",
        "id = ?"
      ]
      rvalue = nil
      additional_conditions = []
      additional_conditions << "category = ?" unless category.empty_or_nil?
      additional_conditions << "sub_category = ?" unless sub_category.empty_or_nil?
      additional_conditions << "size = ?" unless size.empty_or_nil?
      conditions_array = []
      unless search_term.nil? || search_term.empty?
        tags = search_term.split(" ") 
        tags.each(&:strip!)
        tags.delete("size")
        tags.delete("Size")
        base_value = "(#{like_conditions.join(" OR ")})"
        tags.length.times do
          conditions_array << base_value
        end
      else
        tags = []
      end
      if additional_conditions.empty?
        if conditions_array.empty?
          rvalue = []
        else
          rvalue = [conditions_array.join(" OR " )]
        end
      else
        if conditions_array.empty?
          rvalue = [additional_conditions.join(" AND ")]
        else
          rvalue = [additional_conditions.join(" AND ") + " AND (" + conditions_array.join(" OR " ) + ")"]
        end
      end
      rvalue << category unless category.empty_or_nil?
      rvalue << sub_category unless sub_category.empty_or_nil?
      rvalue << size unless size.empty_or_nil?
      for tag in tags
        rvalue << "#{tag} %"
        rvalue << "% #{tag}"
        rvalue << "% #{tag} %"
        rvalue << "%#{tag}%"
        rvalue << tag
      end
      items = featured_items.find(:all, :conditions => rvalue)
      item_array = []
      unless search_term.empty_or_nil?
        for item in items
          tag_count = 0
          tag_count += 100 if item.item_description.not_nil? && item.item_description.downcase.include?(" #{search_term.downcase} ")
          tag_count += 100 if item.item_description.not_nil? && item.item_description.downcase.start_with?(search_term.downcase)
          tag_count += 100 if item.item_description.not_nil? && item.item_description.downcase.end_with?(search_term.downcase)
          tag_count += 50 if item.additional_information.not_nil? && item.additional_information.downcase.include?(" #{search_term.downcase} ")
          tag_count += 50 if item.additional_information.not_nil? && item.additional_information.downcase.start_with?(search_term.downcase)
          tag_count += 50 if item.additional_information.not_nil? && item.additional_information.downcase.end_with?(search_term.downcase)
          for tag in tags
            tag_count += 10 if item.item_description.not_nil? && item.item_description.downcase.split.include?(tag.downcase)
            tag_count += 5 if item.additional_information.not_nil? && item.additional_information.downcase.split.include?(tag.downcase)
          end
          item_array << [item, tag_count]
        end
      else
        for item in items
          item_array << [item, 0]
        end
      end
      return item_array
    end

    def items_to_pick_up
      return 0 if active_items.empty?
      active_items.count(:id, :conditions => ["donate = ?", false])
    end

    def clothing_items_to_pick_up
      return 0 if active_items.empty?
      active_items.count(:id, :conditions => ["donate = ? AND size IS NOT NULL AND size != ?", false, ''])
    end

    def none_clothing_items_to_pick_up
      return 0 if active_items.empty?
      active_items.count(:id, :conditions => ["donate = ? AND (size IS NULL || size = ?)", false, ''])
    end

    def sales_with_item_sold_online
      sale_ids = orders.find(:all, :select => "DISTINCT sale_id")
      sales = Sale.find(:all, :conditions => ["id IN (?)", sale_ids.map{ |sale| sale.sale_id}])
    end

    def pending_orders_for_sale(sale_id)
      pending_orders.find(:all, :conditions => ["sale_id = ? AND pay_pal_order_id IS NULL", sale_id])
    end

    def has_pending_orders_in_sale?(sale_id)
      !pending_orders_for_sale(sale_id).empty?
    end

    def has_no_pending_orders?
      pending_orders.count == 0
    end

    def has_pending_orders?
      !has_no_pending_orders?
    end

    def shopping_cart_sub_total(sale_id)
      rvalue = 0
      for order in pending_orders_for_sale(sale_id)
        rvalue += order.item_price
      end
      rvalue
    end

    def shopping_cart_sales_tax(sale_id)
      rvalue = 0
      for order in pending_orders_for_sale(sale_id)
        rvalue += order.sales_tax
      end
      rvalue
    end

    def shopping_cart_total(sale_id)
      rvalue = 0
      for order in pending_orders_for_sale(sale_id)
        rvalue += order.total_amount
      end
      rvalue
    end

    def shopping_cart_purchase_description(sale_id)
      rvalue = []
      for order in pending_orders_in_sale(sale_id)
        rvalue << "#{order.item_name}, #{order.consignor_inventory_id}"
      end
      rvalue << "#{pending_orders.count} Items Purchased" unless pending_orders.empty?
      rvalue.join("; ")
    end

    def sales_with_pending_items
      rvalue = []
      return rvalue if pending_orders.empty?
      items = pending_orders.find(:all, :select => "DISTINCT sale_id")
      for item in items
        rvalue << item.sale
      end
      rvalue
    end
  end
end
