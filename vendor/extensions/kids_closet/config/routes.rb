ActionController::Routing::Routes.draw do |map|
  map.kids_request_password    '/forms/kids_request_password',    :controller => 'home', :action => 'kids_request_password',   :conditions => { :method => :post }
  map.kids_marketing_sign_up   '/forms/kids_marketing_sign_up',   :controller => 'home', :action => 'kids_marketing_sign_up',  :conditions => { :method => :post }
  map.kids_register_account    '/forms/kids_register_account',    :controller => 'home', :action => 'kids_register_account',   :conditions => { :method => :post }
  map.kids_register_buyer_account    '/forms/kids_register_buyer_account',    :controller => 'home', :action => 'kids_register_buyer_account',   :conditions => { :method => :post }
  map.kids_login    '/forms/kids_login',    :controller => 'home', :action => 'kids_login',   :conditions => { :method => :post }

  map.rewards_profile '/forms/rewards_profile', :controller => 'customer', :action => 'rewards_profile', :conditions => { :method => :post }
  map.featured_photo '/forms/featured_photo/create', :controller => 'customer', :action => 'create_featured_photo', :conditions => { :method => :post }
  map.create_consignor_inventory '/forms/consignor_inventory/create',     :controller => 'customer', :action => 'create_consignor_inventory', :conditions => { :method => :post }
  map.update_consignor_inventory '/forms/consignor_inventory/update/:id', :controller => 'customer', :action => 'update_consignor_inventory', :conditions => { :method => :post }
  map.create_voice_entry '/forms/consignor_inventory/add_voice_entry', :controller => 'customer', :action => 'create_voice_entry', :conditions => { :method => :post }
  map.destroy_active_items '/forms/consignor_inventory/destroy_active_items', :controller => 'customer', :action => 'destroy_active_items', :conditions => { :method => :post }
  map.destroy_inactive_items '/forms/consignor_inventory/destroy_inactive_items', :controller => 'customer', :action => 'destroy_inactive_items', :conditions => { :method => :post }
  map.donate_all_items '/forms/consignor_inventory/donate_all_items', :controller => 'customer', :action => 'donate_all_items', :conditions => { :method => :post }
  map.donate_all_inactive_items '/forms/consignor_inventory/donate_all_inactive_items', :controller => 'customer', :action => 'donate_all_inactive_items', :conditions => { :method => :post }
  map.print_selected_tags '/forms/consignor_inventory/print_selected_tags', :controller => 'customer', :action => 'print_selected_tags', :format => 'pdf', :conditions => { :method => :post }
  map.print_selected_online_tags '/forms/consignor_inventory/print_selected_online_tags', :controller => 'customer', :action => 'print_selected_online_tags', :format => 'pdf', :conditions => { :method => :post }
  map.print_selected_tag '/forms/consignor_inventory/print_selected_tag', :controller => 'customer', :action => 'print_selected_tag', :format => 'pdf', :conditions => { :method => :post }
  map.print_new_tags '/forms/consignor_inventory/print_new_tags', :controller => 'customer', :action => 'print_new_tags', :format => 'pdf', :conditions => { :method => :post }
  map.print_online_sell_tags '/customer/print_online_sell_tags', :controller => 'customer', :action => 'print_online_sell_tags', :format => 'pdf'
  map.download_active_inventory '/customer/download_active_inventory', :controller => 'customer', :action => 'download_active_inventory', :format => 'csv'
  map.download_inactive_inventory '/customer/download_inactive_inventory', :controller => 'customer', :action => 'download_inactive_inventory', :format => 'csv'
  map.purchase_item_with_paypal '/customer/purchase_item_with_paypal/:id', :controller => 'customer', :action => 'purchase_item_with_paypal'
  map.complete_purchase '/customer/complete_purchase/:id', :controller => 'customer', :action => 'complete_purchase'
  map.process_shopping_cart '/customer/process_shopping_cart', :controller => 'customer', :action => 'process_shopping_cart'
  map.cancel_purchase '/customer/cancel_purchase/:id', :controller => 'customer', :action => 'cancel_purchase'
  map.delete_featured_photo '/customer/delete_featured_photo/:id', :controller => 'customer', :action => 'delete_featured_photo', :conditions => { :method => :delete }
  map.delete_cart_item '/customer/delete_cart_item/:id', :controller => 'customer', :action => 'delete_cart_item', :conditions => { :method => :delete }
  map.rotate_featured_photo_clockwise '/customer/rotate_featured_photo_clockwise/:id', :controller => 'customer', :action => 'rotate_featured_photo_clockwise'
  map.rotate_featured_photo_counter_clockwise '/customer/rotate_featured_photo_counter_clockwise/:id', :controller => 'customer', :action => 'rotate_featured_photo_counter_clockwise'
  map.print_selected_tag '/customer/print_selected_tag/:id', :controller => 'customer', :action => 'print_selected_tag', :format => 'pdf'

#  map.sale_flyer '/home/sale_flyer/:id', :controller => 'home', :action => 'sale_flyer', :format => 'html'
  map.sale_flyer '/home/sale_flyer/:id', :controller => 'home', :action => 'sale_flyer', :format => 'pdf'

  map.become_consignor '/customer/become_consignor/:id', :controller => 'customer', :action => 'become_consignor'
  map.sign_up_for_active_sale '/customer/sign_up_for_active_sale/:id', :controller => 'customer', :action => 'sign_up_for_active_sale'
  map.become_volunteer '/customer/become_2017_volunteer/:id', :controller => 'customer', :action => 'become_2017_volunteer'
  map.become_2017_volunteer '/customer/become_volunteer/:id', :controller => 'customer', :action => 'become_volunteer'
  map.become_member '/home/become_member/:id', :controller => 'home', :action => 'become_member'
  map.become_buyer '/home/become_buyer/:id', :controller => 'home', :action => 'become_buyer'
  map.cancel_consignor '/customer/cancel_consignor/:id', :controller => 'customer', :action => 'cancel_consignor', :conditions => { :method => :delete }
  map.cancel_volunteer '/customer/cancel_volunteer/:id', :controller => 'customer', :action => 'cancel_volunteer', :conditions => { :method => :delete }
  map.cancel_inactive_franchise '/customer/cancel_inactive_franchise/:id', :controller => 'customer', :action => 'cancel_inactive_franchise', :conditions => { :method => :delete }
  map.make_card_primary '/customer/make_card_primary/:id', :controller => 'customer', :action => 'make_card_primary', :condiitions => {:method => :get}

  map.unsubscribe_franchise_profile '/home/unsubscribe_franchise_profile/:id', :controller => 'home', :action => 'unsubscribe_franchise_profile'
  map.unsubscribe_profile '/home/unsubscribe_profile/:id', :controller => 'home', :action => 'unsubscribe_profile'

  map.destroy_item '/customer/destroy_item/:id', :controller => 'customer', :action => 'destroy_item', :conditions => { :method => :delete }
  map.destroy_inactive_item '/customer/destroy_inactive_item/:id', :controller => 'customer', :action => 'destroy_inactive_item', :conditions => { :method => :delete }
  map.make_active_item '/customer/make_active_item/:id', :controller => 'customer', :action => 'make_active_item', :conditions => { :method => :delete }
  map.make_inactive_item '/customer/make_inactive_item/:id', :controller => 'customer', :action => 'make_inactive_item', :conditions => { :method => :delete }
  map.make_item_not_featured '/customer/make_item_not_featured/:id', :controller => 'customer', :action => 'make_item_not_featured', :conditions => { :method => :delete }
  map.donate_item '/customer/donate_item/:id', :controller => 'customer', :action => 'donate_item', :conditions => { :method => :delete }
  map.donate_inactive_item '/customer/donate_inactive_item/:id', :controller => 'customer', :action => 'donate_inactive_item', :conditions => { :method => :delete }
  map.cancel_volunteer_job '/customer/cancel_volunteer_job/:id', :controller => 'customer', :action => 'cancel_volunteer_job', :conditions => { :method => :delete }
  map.set_sale '/home/set_sale/:id', :controller => 'home', :action => 'set_sale'
  map.drop_off_times '/customer/drop_off_times/:id', :controller => 'customer', :action => 'drop_off_times'
  map.select_drop_off_time '/customer/select_drop_off_time/:id', :controller => 'customer', :action => 'select_drop_off_time'
  map.volunteer_jobs '/customer/volunteer_jobs/:id', :controller => 'customer', :action => 'volunteer_jobs'
  map.select_volunteer_job '/customer/select_volunteer_job/:id', :controller => 'customer', :action => 'select_volunteer_job'
  map.connect 'promo_code_report',  :controller => 'admin/sales', :action => 'promo_code_report'
  map.namespace :admin, :member => { :remove => :get } do |admin|
    admin.resources :sale_seasons, :member => {
                                :reports => :get,
                                :archive => :post
                              }
    admin.resources :franchises, :member => {
                                :consignors => :get, 
                                :volunteers => :get, 
                                :mailing_list_members => :get,
                                :profile_list => :get,
                                :rewards_list => :get,
                                :import_members => :get,
                                :export_members => :get,
                                :export_texting_profiles => :get,
                                :process_member_import => :put,
                                :rewards_available => :get,
                                :update_content => :put,
                                :found_us_report => :get,
                                :import_data => :get,
                                :bad_email_export => :get,
                                :bad_email_list => :get,
                                :rewards_export => :get,
                                :consignors_history => :get,
                                :consignors_history_export => :get,
                                :volunteers_history => :get,
                                :volunteers_history_export => :get,
                                :score_card_export => :get
                              }
    admin.resources :franchise_file_categories
    admin.resources :franchise_files, :path_prefix => '/franchise_file_categories/:franchise_file_category_id', :name_prefix => 'admin_franchise_file_category_'
    admin.resources :franchise_home_contents, :path_prefix => '/franchses/:franchise_id', :name_prefix => 'admin_franchise_'
    admin.resources :franchise_owner_profiles, :path_prefix => '/franchises/:franchise_id', :name_prefix => 'admin_franchise_'
    admin.resources :franchise_profiles, :path_prefix => '/franchises/:franchise_id', :name_prefix => 'admin_franchise_', :member => {
                                :bad_email => :post,
                                :good_email => :post,
                                :remove => :post
                              }
    admin.resources :franchise_photos, :path_prefix => '/franchises/:franchise_id', :name_prefix => 'admin_franchise_'
    admin.resources :franchise_rewards_adjustments, :path_prefix => '/franchises/:franchise_id', :name_prefix => 'admin_franchise_'
    admin.resources :kids_emails, :path_prefix => '/franchise/:franchise_id', :name_prefix => 'admin_franchise_', :except => [:show]
    admin.resources :kids_emails, :path_prefix => '/franchise/:franchise_id', :member => {:email_volunteers_in_job => :get, :send_email_to_volunteers_in_job => :post}
    admin.resources :kids_master_emails
    admin.resources :check_printers, :path_prefix => '/sales/:sale_id', :name_prefix => 'admin_sale_'
    admin.resources :rewards_earning, :path_prefix => '/sales/:sale_id', :name_prefix => 'admin_sale_'
    admin.resources :sale_consignor_times, :path_prefix => '/sales/:sale_id', :name_prefix => 'admin_sale_', :except => [:show]
    admin.resources :sale_consignor_times, :member => {:print_consignor_list => :get}
    admin.resources :sale_consignor_sign_ups, :member => {:consignor_contract => :get, :update_sale_percentage => :post}
    admin.resources :sale_volunteer_times, :path_prefix => '/sales/:sale_id', :name_prefix => 'admin_sale_', :except => [:show]
    admin.resources :sale_volunteer_times, :member => {:print_volunteer_list => :get, :make_active => :post}
    admin.resources :sale_volunteer_sign_ups
    admin.resources :business_partners, :path_prefix => '/sales/:sale_id', :name_prefix => 'admin_sale_'
    admin.resources :pay_pal_orders, :member => {
                                :cancel_order => :delete,
                                :comfirm_order => :delete
                              }
    admin.resources :sales, :path_prefix => '/franchises/:franchise_id', :name_prefix => 'admin_franchise_', :except => [:show]
    admin.resources :sales, :member => {
                                :make_active => :post,
                                :deactivate_sale => :post, 
                                :upload_pdf => :put,
                                :consignors => :get,
                                :print_sort_labels => :get,
                                :volunteers => :get,
                                :print_volunteers => :get,
                                :rewards_manager => :get,
                                :rewards_list => :get,
                                :rewards_history => :get,
                                :apply_reward => :post,
                                :remove_reward => :post,
                                :reports => :get,
                                :buyer_item_reports => :get,
                                :financial_report => :get,
                                :promo_codes => :get,
                                :calculate_financials => :get,
                                :consignors_report => :get,
                                :volunteers_report => :get,
                                :check_report => :get,
                                :pick_up_report => :get,
                                :sales_export => :get,
                                :online_sales_export => :get,
                                :online_sales_report => :get,
                                :print_online_sales_report => :get,
                                :checks_export => :get,
                                :print_all_volunteer_lists => :get,
                                :print_volunteer_jobs => :get,
                                :print_all_consignor_lists => :get,
                                :print_drop_off_times => :get,
                                :consignors_export => :get,
                                :consignors_history => :get,
                                :consignors_history_export => :get,
                                :volunteers_history => :get,
                                :volunteers_history_export => :get, 
                                :consignors_and_volunteers_export => :get, 
                                :make_all_jobs_active => :post,
                                :expired_pay_pal_orders => :get
                              }
    admin.resources :consignor_inventories, :path_prefix => '/sales/:sale_id', :name_prefix => 'admin_sale_', :member => {
                                :items_coming => :get,
                                :items_selling_online => :get,
                                :items_coming_export => :get,
                                :return => :post,
                                :print_tags => :get,
                                :remove_featured_item => :delete
                              }
    admin.resources :featured_photos, :path_prefix => '/sales/:sale_id', :name_prefix => 'admin_sale_', :member => {
                                :rotate_clockwise => :get,
                                :rotate_counter_clockwise => :get 
                              }
    admin.resources :transaction_imports, :path_prefix => '/sales/:sale_id', :name_prefix => 'admin_sale_', :except => [:show]
    admin.resources :transaction_imports, :member => {
                                :process_import => :post, 
                                :rollback_import => :post,
                                :log => :get
                              }
    admin.resources :rewards_imports, :path_prefix => '/sales/:sale_id', :name_prefix => 'admin_sale_', :except => [:show]
  end
end