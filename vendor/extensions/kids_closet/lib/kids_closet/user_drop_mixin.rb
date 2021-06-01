module KidsCloset
  module UserDropMixin
    include WillPaginate::Liquidized::ViewHelpers

    def sort_group
      @profile.sort_column
    end

    def active_franchise_profiles
      rvalue = []
      @profile.franchise_profiles.find(:all, :conditions => ["franchise_profiles.active = ?", true]).each do |franchise_profile|
        sale = Sale.current_active_sale(franchise_profile.franchise_id)
        if !sale.nil?
          rvalue << FranchiseProfileDrop.new(franchise_profile, user) if SaleConsignorSignUp.consignor_sign_up_for_sale(sale.id, franchise_profile.id).not_nil? || !SaleVolunteerSignUp.volunteer_sign_ups_for_sale(sale.id, franchise_profile.id).empty?
        end
      end
      rvalue
    end

    def inactive_franchise_profiles
      rvalue = []
      @profile.franchise_profiles.find(:all, :conditions => ["franchise_profiles.active = ?", true]).each do |franchise_profile|
        sale = Sale.current_active_sale(franchise_profile.franchise_id)
        if !sale.nil?
          rvalue << FranchiseProfileDrop.new(franchise_profile, user) if SaleConsignorSignUp.consignor_sign_up_for_sale(sale.id, franchise_profile.id).nil? && SaleVolunteerSignUp.volunteer_sign_ups_for_sale(sale.id, franchise_profile.id).empty?
        end
      end
      rvalue
    end

    def has_active_franchises?
      @profile.franchise_profiles.length > 0
    end

    def has_active_franchise_profile?
      !active_franchise_profiles.empty?
    end
    
    def has_inactive_franchises?
      !inactive_franchise_profiles.empty?
    end
    
    def sales_signed_up_in_current_season
      rvalue = []
      SaleConsignorSignUp.current_season_sign_ups_for_profile(@profile.id).each do |sign_up|
        rvalue << SaleConsignorSignUpDrop.new(sign_up)
      end
      rvalue
    end  

    def has_no_current_season_sales?
      return !has_active_franchise_profile? && has_inactive_franchises?
    end

    def current_season
      SaleSeason.current_sale_season
    end

    def prior_season
      SaleSeason.prior_season
    end

    def is_franchise_owner?
      @profile.franchise_owner_profiles.length > 0
    end

    def active_items
      page_of_active_items.map{ |item| ItemDrop.new(item) }
    end

    def inactive_items
      page_of_inactive_items.map{ |item| ItemDrop.new(item) }
    end

    def paginate_active_items
      will_paginate_liquid(page_of_active_items) unless active_items.empty?
    end
    
    def paginate_inactive_items
      will_paginate_liquid(page_of_inactive_items) unless inactive_items.empty?
    end
    
    def sold_items
      page_of_sold_items.map{ |item| ItemDrop.new(item) }
    end

    def paginate_sold_items
      will_paginate_liquid(page_of_sold_items) unless sold_items.empty?
    end
    
    def donated_items
      page_of_donated_items.map{ |item| ItemDrop.new(item) }
    end

    def paginate_donated_items
      will_paginate_liquid(page_of_donated_items) unless donated_items.empty?
    end

    def featured_items
      page_of_featured_items.map{ |item| ItemDrop.new(item) }
    end

    def paginate_featured_items
      will_paginate_liquid(page_of_featured_items) unless featured_items.empty?
    end

    def online_orders
      page_of_orders.map{ |item| OrderDrop.new(item) }
    end

    def paginate_online_orders
      will_paginate_liquid(page_of_orders) unless online_orders.empty?
    end

    def online_sales
      page_of_online_sales.map{ |item| OrderDrop.new(item) }
    end

    def paginate_online_sales
      will_paginate_liquid(page_of_online_sales) unless online_sales.empty?
    end
    
    def number_of_active_items
      @profile.active_items.count
    end
        
    def number_of_inactive_items
      @profile.inactive_items.count
    end
        
    def number_of_sold_items
      @profile.sold_items.count(:id, :conditions => ["sale_date >= ? AND sale_date <= ?", prior_season.start_date, current_season.end_date])
    end
    
    def number_of_items
      @profile.items.count
    end
        
    def number_of_donated_items
      @profile.donated_items.count
    end

    def number_of_featured_items
      @profile.featured_items.count
    end

    def number_of_orders
      @profile.orders.count
    end

    def number_of_online_sales
      @profile.sells.count
    end

    def total_unsold
      @profile.active_items.sum(:price)
    end

    def total_sold
      @profile.sold_items.sum(:sale_price, :conditions => ["sale_date >= ? AND sale_date <= ?", prior_season.start_date, current_season.end_date])
    end
           
    def total_donated
      @profile.donated_items.sum(:price)
    end
   
    def inventory
      rvalue = []
      @profile.items.each do |item|
        rvalue << ItemDrop.new(item)
      end
      rvalue
    end
   
    def active_items_print_list
      @profile.active_items.map{ |item| ItemDrop.new(item) }
    end
      
    def inactive_items_print_list
      @profile.inactive_items.map{ |item| ItemDrop.new(item) }
    end
      
    def sold_items_print_list
      rvalue = []
      @profile.sold_items.find(:all, :conditions => ["sale_date >= ? AND sale_date <= ?", prior_season.start_date, current_season.end_date]).each do |item|
        rvalue << ItemDrop.new(item)
      end
      rvalue
    end
    
    def donated_items_print_list
      rvalue = []
      @profile.donated_items.each do |item|
        rvalue << ItemDrop.new(item)
      end
      rvalue
    end
      
    def reward_cards   
      rvalue = []
      @profile.rewards_profiles.find(:all).each do |reward_card|
        rvalue << RewardsProfileDrop.new(reward_card)
      end
      rvalue
    end  
    
    def number_of_rewards_cards
      @profile.rewards_profiles.count
    end
    
    def rewards_activity
      rvalue = []
      RewardsProfile.sales_for_profile(@profile).each do |sale|
        rvalue << RewardsProfileSaleDrop.new(@profile, sale)
      end
      rvalue      
    end
    
    def rewards_franchises
      rvalue = []
      RewardsProfile.franchises_for_profile(@profile).each do |franchise|
        rvalue << RewardsProfileFranchiseDrop.new(@profile, franchise)
      end
      rvalue            
    end
    
    def rewards_earned
      rvalue = []
      @profile.rewards_earnings.each do |earning|
        rvalue << RewardsEarningDrop.new(earning)
      end
      rvalue
    end

    def reward_adjustments
      rvalue = []
      @profile.franchise_rewards_adjustments.each do |adjustment|
        rvalue << RewardsAdjustmentDrop.new(adjustment)
      end
      rvalue
    end

    def sales_with_items_sold_online
      rvalue = []
      for sale in @profile.sales_with_item_sold_online
        rvalue << OnlineSaleDrop.new(sale, @profile)
      end
      rvalue
    end

    def pending_orders
      rvalue = []
      @profile.pending_pay_pal_orders.each do |item|
        rvalue << PayPalOrderDrop.new(item)
      end
      rvalue
    end

    def has_shopping_cart?
      @profile.has_pending_orders?
    end

    def sales_with_shopping_cart
      rvalue = []
      for sale in @profile.sales_with_pending_items
        rvalue << SaleDrop.new(sale, @user)
      end
      rvalue
    end

    private

    def page_of_active_items
      @profile.active_items.paginate(
        :per_page => 80,
        :page => @context.registers[:controller].send(:params)[:page]
      )
    end

    def page_of_inactive_items
      @profile.inactive_items.paginate(
        :per_page => 80,
        :page => @context.registers[:controller].send(:params)[:page]
      )
    end

    def page_of_sold_items
      @profile.sold_items.paginate(
        :per_page => 100,
        :page => @context.registers[:controller].send(:params)[:page],
        :conditions => ["sale_date >= ? AND sale_date <= ?", prior_season.start_date, current_season.end_date]
      )
    end

    def page_of_donated_items
      @profile.donated_items.paginate(
        :per_page => 100,
        :page => @context.registers[:controller].send(:params)[:page]
      )
    end

    def page_of_featured_items
      @profile.featured_items.paginate(
        :per_page => 100,
        :page => @context.registers[:controller].send(:params)[:page]
      )
    end

    def page_of_orders
      @profile.orders.paginate(
        :per_page => 100,
        :page => @context.registers[:controller].send(:params)[:page]
      )
    end

    def page_of_online_sales
      @profile.sells.paginate(
        :per_page => 100,
        :page => @context.registers[:controller].send(:params)[:page]
      )
    end

  end  
end