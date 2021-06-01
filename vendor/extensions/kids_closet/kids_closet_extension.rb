# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

class KidsClosetExtension < Bionic::Extension
  version "1.0"
  description "Adds all the functionality for the KidsCloset website"
  url "http://www.bionccms.com/kids_closet"

  CustomerController.send(:include, KidsCloset::CustomerControllerMixin)
  HomeController.send(:include, KidsCloset::HomeControllerMixin)
  User.send(:include, KidsCloset::UserMixin)
  Profile.send(:include, KidsCloset::ProfileMixin)
  SiteAsset.send(:include, KidsCloset::SiteAssetMixin)
  SiteDrop.send(:include, KidsCloset::SiteDropMixin)
  UserDrop.send(:include, KidsCloset::UserDropMixin)
  ProfileSearch.send(:include, KidsCloset::ProfileSearchMixin)
#  Delayed::Backend::ActiveRecord::Job.send(:include, KidsCloset::DelayedJobMixin)
  def activate
    handle = admin_interface.navigation.add "Kids Closet", "#", :after => "Site Management"
    admin_interface.navigation.send(handle.to_sym).add "Franchises", "/admin/franchises"
    admin_interface.navigation.send(handle.to_sym).add "Franchise Files", "/admin/franchise_file_categories", :after => "Franchises"
    admin_interface.navigation.send(handle.to_sym).add "Sale Seasons", "/admin/sale_seasons", :after => "Franchises"
    admin_interface.navigation.send(handle.to_sym).add  "Email System", "/admin/kids_master_emails", :before => "Sale Seasons"
    
    Bionic::AdminInterface.class_eval do
      attr_accessor :franchises
      attr_accessor :franchise_profiles
      attr_accessor :franchise_owner_profiles
      attr_accessor :sales
      attr_accessor :franchise_photos
      attr_accessor :sale_consignor_times
      attr_accessor :sale_volunteer_times
      attr_accessor :sale_consignor_sign_ups
      attr_accessor :sale_volunteer_sign_ups
      attr_accessor :transaction_imports
      attr_accessor :rewards_imports
      attr_accessor :franchise_file_categories
      attr_accessor :franchise_files
      attr_accessor :sale_seasons
      attr_accessor :consignor_inventories
      attr_accessor :kids_emails
      attr_accessor :kids_master_emails
      attr_accessor :check_printers
      attr_accessor :business_partners
      attr_accessor :franchise_rewards_adjustments
      attr_accessor :franchise_home_contents
    end
    admin_interface.franchises = load_default_franchises_regions
    admin_interface.franchise_profiles = load_default_franchise_profiles_regions
    admin_interface.franchise_owner_profiles = load_default_franchises_owner_profile_regions
    admin_interface.sales = load_default_sales_regions
    admin_interface.franchise_photos = load_default_franchise_photos_regions
    admin_interface.sale_consignor_times = load_default_sale_consignor_times_regions
    admin_interface.sale_volunteer_times = load_default_sale_volunteer_times_regions
    admin_interface.sale_consignor_sign_ups = load_default_sale_consignor_sign_ups_regions
    admin_interface.sale_volunteer_sign_ups = load_default_sale_volunteer_sign_ups_regions
    admin_interface.transaction_imports = load_default_transaction_imports_regions
    admin_interface.rewards_imports = load_default_rewards_imports_regions
    admin_interface.franchise_file_categories = load_default_franchise_file_category_regions
    admin_interface.franchise_files = load_default_franchise_file_regions
    admin_interface.sale_seasons = load_default_sale_seasons_regions
    admin_interface.consignor_inventories = load_default_consignor_inventories_regions
    admin_interface.kids_emails = load_default_kids_emails_regions
    admin_interface.kids_master_emails = load_default_kids_emails_regions
    admin_interface.check_printers = load_default_check_printers_regions
    admin_interface.business_partners = load_default_business_partners_regions
    admin_interface.franchise_rewards_adjustments = load_default_franchise_rewards_adjustments_regions
    admin_interface.franchise_home_contents = load_default_franchise_home_contents_regions

#    Bionic::FormForOptions.instance.custom_actions << {
#      :form_action => "consignor_inventory",
#      :model => 'consignor_inventory',
#      :new_url => "/forms/consignor_inventory/create",
#      :edit_url => "/forms/consignor_inventory/update/:id"
#    }

    Bionic::FormForOptions.instance.custom_actions << {
      :form_action => "rewards_profile",
      :model => 'rewards_profile',
      :new_url => "/forms/rewards_profile/",
      :edit_url => "/forms/rewards_profile/"
    }

    Bionic::FormForOptions.instance.custom_actions << {
      :form_action => "featured_photo",
      :model => 'featured_photo',
      :new_url => "/forms/featured_photo/create",
      :edit_url => "/forms/featured_photo/"
    }
    Bionic::FormForOptions.instance.custom_actions << {
      :form_action => "destroy_item",
      :model => 'consignor_inventory',
      :new_url => "/forms/consignor_inventory/destroy_item/:id",
      :edit_url => "/forms/consignor_inventory/destroy_item/:id"
    }

    Bionic::FormForOptions.instance.custom_actions << {
      :form_action => "destroy_inactive_item",
      :model => 'consignor_inventory',
      :new_url => "/forms/consignor_inventory/destroy_inactive_item/:id",
      :edit_url => "/forms/consignor_inventory/destroy_inactive_item/:id"
    }

    Bionic::FormForOptions.instance.custom_actions << {
      :form_action => "donate_item",
      :model => 'consignor_inventory',
      :new_url => "/forms/consignor_inventory/donate_item/:id",
      :edit_url => "/forms/consignor_inventory/donate_item/:id"
    }

    Bionic::FormForOptions.instance.custom_actions << {
      :form_action => "make_active_item",
      :model => 'consignor_inventory',
      :new_url => "/forms/consignor_inventory/make_active_item/:id",
      :edit_url => "/forms/consignor_inventory/make_active_item/:id"
    }

    Bionic::FormForOptions.instance.custom_actions << {
      :form_action => "donate_inactive_item",
      :model => 'consignor_inventory',
      :new_url => "/forms/consignor_inventory/donate_inactive_item/:id",
      :edit_url => "/forms/consignor_inventory/donate_inactive_item/:id"
    }

    Bionic::FormForOptions.instance.custom_actions << {
      :form_action => "destroy_active_items",
      :model => 'consignor_inventory',
      :new_url => "/forms/consignor_inventory/destroy_active_items",
      :edit_url => "/forms/consignor_inventory/destroy_active_items"
    }

    Bionic::FormForOptions.instance.custom_actions << {
      :form_action => "destroy_inactive_items",
      :model => 'consignor_inventory',
      :new_url => "/forms/consignor_inventory/destroy_inactive_items",
      :edit_url => "/forms/consignor_inventory/destroy_inactive_items"
    }

    Bionic::FormForOptions.instance.custom_actions << {
      :form_action => "donate_all_items",
      :model => 'consignor_inventory',
      :new_url => "/forms/consignor_inventory/donate_all_items",
      :edit_url => "/forms/consignor_inventory/donate_all_items"
    }

    Bionic::FormForOptions.instance.custom_actions << {
      :form_action => "donate_all_inactive_items",
      :model => 'consignor_inventory',
      :new_url => "/forms/consignor_inventory/donate_all_inactive_items",
      :edit_url => "/forms/consignor_inventory/donate_all_inactive_items"
    }

    Bionic::FormForOptions.instance.custom_actions << {
      :form_action => "print_selected_tags",
      :model => 'consignor_inventory',
      :new_url => "/forms/consignor_inventory/print_selected_tags",
      :edit_url => "/forms/consignor_inventory/print_selected_tags"
    }

    Bionic::FormForOptions.instance.custom_actions << {
      :form_action => "print_selected_online_tags",
      :model => 'consignor_inventory',
      :new_url => "/forms/consignor_inventory/print_selected_online_tags",
      :edit_url => "/forms/consignor_inventory/print_selected_online_tags"
    }

    Bionic::FormForOptions.instance.custom_actions << {
      :form_action => "print_new_tags",
      :model => 'consignor_inventory',
      :new_url => "/forms/consignor_inventory/print_new_tags",
      :edit_url => "/forms/consignor_inventory/print_new_tags"
    }

#    Bionic::FormForOptions.instance.custom_actions << {
#      :form_action => "print_online_sell_tags",
#      :model => 'consignor_inventory',
#      :new_url => "/forms/consignor_inventory/print_online_sell_tags",
#      :edit_url => "/forms/consignor_inventory/print_online_sell_tags"
#    }

    Bionic::FormForOptions.instance.custom_actions << {
      :form_action => "print_online_tags",
      :model => 'consignor_inventory',
      :new_url => "/forms/consignor_inventory/print_online_tags",
      :edit_url => "/forms/consignor_inventory/print_online_tags"
    }
    
    Bionic::FormForOptions.instance.custom_actions << {
      :form_action => "analize_voice_entry",
      :model => 'consignor_inventory',
      :new_url => "/forms/consignor_inventory/add_voice_entry",
      :edit_url => nil
    }

    Bionic::FormForOptions.instance.custom_actions << {
      :form_action => "kids_request_password",
      :model => nil,
      :new_url => "/forms/kids_request_password",
      :edit_url => "/forms/kids_request_password"
    }

    Bionic::FormForOptions.instance.custom_actions << {
      :form_action => "kids_marketing_sign_up",
      :model => 'profile',
      :new_url => "/forms/kids_marketing_sign_up",
      :edit_url => "/forms/kids_marketing_sign_up"
    }
    
    Bionic::FormForOptions.instance.custom_actions << {
      :form_action => "kids_register_account",
      :model => 'profile',
      :new_url => "/forms/kids_register_account",
      :edit_url => "/forms/kids_register_account"
    }

    Bionic::FormForOptions.instance.custom_actions << {
      :form_action => "kids_register_buyer_account",
      :model => 'profile',
      :new_url => "/forms/kids_register_buyer_account",
      :edit_url => "/forms/kids_register_buyer_account"
    }

    Bionic::FormForOptions.instance.custom_actions << {
      :form_action => "kids_login",
      :model => 'user',
      :new_url => "/forms/kids_login",
      :edit_url => "/forms/kids_login"
    }
  end

  def deactivate
  end

  def load_default_franchises_regions
    returning OpenStruct.new do |franchises|
      franchises.index = Bionic::AdminInterface::RegionSet.new do |index|
        index.top.concat %w{pagination_counts}
        index.before_list.concat %w{}
        index.list_headers.concat %w{franchise_name_column_header sale_city_column_header}
        index.list_headers.concat %w{sale_state_column_header actions_column_header}
        index.list_data.concat %w{franchise_name_column sale_city_column sale_state_column actions_column}
        index.after_list.concat %w{pagination_links}
        index.action_row.concat %w{new_franchise}
        index.bottom.concat %w{}
        index.right_side.concat %w{}
      end
      franchises.show = Bionic::AdminInterface::RegionSet.new do |show|
        show.above_content.concat %w{action_list}
        show.tab_header.concat %w{franchise_sales_tab_header mini_content_tab_header franchise_info_tab_header franchise_owners_tab_header}
        show.tabs.concat %w{franchise_sales_tab mini_content_tab franchise_info_tab franchise_owners_tab}
        show.main.concat %w{edit_form}
        show.mini_content_list_content.concat %w{content_form_header mini_content_form}
        show.mini_content_content_form_top.concat %w{}
        show.mini_content_content_form.concat %w{content_name_tabs content_form_editor}
        show.mini_content_content_form_bottom.concat %w{content_form_buttons mini_content_tab_javascript}
        show.franchise_owner_list_headers.concat %w{franchise_owner_name_column_header franchise_owner_email_column_header}
        show.franchise_owner_list_headers.concat %w{franchise_owner_external_email_header franchise_owner_pay_pal_email_column_header}
        show.franchise_owner_list_headers.concat %w{franchise_owner_phone_column_header actions_column_header}
        show.franchise_owner_list_data.concat %w{franchise_owner_name_column franchise_owner_email_column franchise_owner_external_email_column}
        show.franchise_owner_list_data.concat %w{franchise_owner_pay_pal_email_column franchise_owner_phone_column actions_column}
        show.franchise_sale_list_headers.concat %w{sale_dates_column_header sale_address_column_header active_sale_column_header actions_column_header}
        show.franchise_sale_list_data.concat %w{sale_dates_column sale_address_column active_sale_column actions_column}
        show.after_list.concat %w{pagination_links}
        show.franchise_owners_action_row.concat %w{new_franchise_owner_profile}
        show.franchise_sales_action_row.concat %w{new_franchise_sale}
        show.below_content.concat %w{tab_javascript}
        show.right_side.concat %w{franchise_links profile_search data_import}
      end
      franchises.update_content = franchises.show
      franchises.consignors = Bionic::AdminInterface::RegionSet.new do |consignors|
        consignors.before_list.concat %w{}
        consignors.top.concat %w{pagination_counts}
        consignors.list_headers.concat %w{number_column_header sort_column_header name_column_header email_column_header} 
        consignors.list_headers.concat %w{phone_column_header consignor_column_header volunteer_column_header}
        consignors.list_headers.concat %w{mailing_list_column_header transfer_column_header actions_column_header}
        consignors.list_data.concat %w{number_column sort_column name_column email_column phone_column consignor_column}
        consignors.list_data.concat %w{volunteer_column mailing_list_column transfer_column actions_column}
        consignors.after_list.concat %w{pagination_links}
        consignors.action_row.concat %w{franchises_path}
        consignors.right_side.concat %w{franchise_links profile_search}
      end
      franchises.volunteers = franchises.consignors
      franchises.mailing_list_members = franchises.consignors
      franchises.profile_list = franchises.consignors
      franchises.bad_email_list = franchises.consignors
      franchises.consignors_history = Bionic::AdminInterface::RegionSet.new do |consignors|
        consignors.before_list.concat %w{}
        consignors.top.concat %w{pagination_counts}
        consignors.list_headers.concat %w{number_column_header sort_group_column_header first_name_column_header}
        consignors.list_headers.concat %w{last_name_column_header created_at_column_header last_consign_date_column_header} 
        consignors.list_headers.concat %w{number_events_column_header life_time_proceeds_column_header}
        consignors.list_headers.concat %w{last_sale_proceeds_column_header lifetime_items_column_header last_sale_items_column_header}
        consignors.list_headers.concat %w{unsold_items_column_header unsold_value_column_header inactive_items_column_header}
        consignors.list_data.concat %w{number_column sort_group_column first_name_column last_name_column created_at_column}
        consignors.list_data.concat %w{last_consign_date_column number_events_column life_time_proceeds_column last_sale_proceeds_column}
        consignors.list_data.concat %w{lifetime_items_column last_sale_items_column unsold_items_column unsold_value_column inactive_items_column}
        consignors.after_list.concat %w{pagination_links}
        consignors.action_row.concat %w{franchises_path}
        consignors.right_side.concat %w{franchise_links profile_history_search}
      end
      franchises.volunteers_history = Bionic::AdminInterface::RegionSet.new do |volunteers|
        volunteers.before_list.concat %w{}
        volunteers.top.concat %w{pagination_counts}
        volunteers.list_headers.concat %w{number_column_header name_column_header email_column_header}
        volunteers.list_headers.concat %w{phone_column_header created_at_column_header last_volunteer_date_column_header} 
        volunteers.list_headers.concat %w{last_sale_jobs_column_header lifetime_jobs_column_header number_events_column_header}
        volunteers.list_data.concat %w{number_column name_column email_column phone_column created_at_column}
        volunteers.list_data.concat %w{last_volunteer_date_column last_sale_jobs_column lifetime_jobs_column number_events_column}
        volunteers.after_list.concat %w{pagination_links}
        volunteers.action_row.concat %w{franchises_path}
        volunteers.right_side.concat %w{franchise_links profile_search}
      end
      franchises.edit = Bionic::AdminInterface::RegionSet.new do |edit|
        edit.main.concat %w{edit_form}
        edit.form_top.concat %w{edit_errors}
        edit.form.concat %w{edit_franchise_name edit_sale_city edit_province_id edit_royalty_status}
        edit.form.concat %w{edit_franchise_meta_keywords edit_franchise_meta_description edit_franchise_email edit_external_email edit_pay_pal_email}
        edit.form.concat %w{edit_facebook_url edit_facebook_pixel edit_google_analytics edit_twitter_url edit_blogger_url}
        edit.form_bottom.concat %w{edit_buttons}
        edit.right_side.concat %w{}
      end
      franchises.new = franchises.edit
      franchises.rewards_available = Bionic::AdminInterface::RegionSet.new do |rewards_available|
        rewards_available.top.concat %w{pagination_counts}
        rewards_available.before_list.concat %w{}
        rewards_available.list_headers.concat %w{rewards_number_column_header name_column_header sale_season_column_header amount_purchased_column_header}
        rewards_available.list_headers.concat %w{amount_earned_column_header awards_applied_column_header awards_available_column_header}
        rewards_available.list_data.concat %w{rewards_number_column name_column sale_season_column amount_purchased_column}
        rewards_available.list_data.concat %w{amount_earned_column awards_applied_column awards_available_column}
        rewards_available.after_list.concat %w{pagination_links}
        rewards_available.action_row.concat %w{franchises_path}
        rewards_available.right_side.concat %w{franchise_links rewards_search}
      end
      franchises.rewards_list = franchises.rewards_available
      franchises.import_members = Bionic::AdminInterface::RegionSet.new do |import|
        import.main.concat %w{edit_form}        
        import.form_top.concat %w{edit_errors}
        import.site_asset_fields.concat %w{edit_filename}
        import.franchise_profile_fields.concat %w{edit_franchise_id}
        import.form_bottom.concat %w{edit_buttons}
        import.right_side.concat %w{import_help}
      end
      franchises.process_member_import = franchises.import_members
      franchises.found_us_report = Bionic::AdminInterface::RegionSet.new do |found_us|
        found_us.above_content.concat %w{action_list}
        found_us.tab_header.concat %w{found_us_stats_tab_header referrals_tab_header others_tab_header}
        found_us.tabs.concat %w{found_us_stats_tab referrals_tab others_tab}
        found_us.found_us_stats_list_headers.concat %w{label_column_header count_column_header}
        found_us.found_us_stats_list_data.concat %w{label_column count_column}
        found_us.referrals_list_headers.concat %w{consignor_column_header referred_by_column_header date_signed_up_column_header}
        found_us.referrals_list_data.concat %w{consignor_column referred_by_column date_signed_up_column}
        found_us.other_reasons_list_headers.concat %w{other_reason_column_header count_column_header}
        found_us.other_reason_list_data.concat %w{label_column count_column}
        found_us.below_content.concat %w{tab_javascript}
        found_us.right_side.concat %w{franchise_links profile_search}
      end
      franchises.import_data = Bionic::AdminInterface::RegionSet.new do |import|
        import.right_side.concat %w{}
      end
    end
  end

  def load_default_franchise_home_contents_regions
    returning OpenStruct.new do |franchise_home_content|
      franchise_home_content.index = Bionic::AdminInterface::RegionSet.new do |index|
        index.above_content.concat %w{action_list}
        index.tab_header.concat %w{franchise_home_content}
        index.tabs.concat %w{franchise_home_content_tab}
        index.main.concat %w{edit_form}
        index.franchise_home_content_list_content.concat %w{content_form_header franchise_home_content_form}
        index.franchise_home_content_content_form_top.concat %w{}
        index.franchise_home_content_content_form.concat %w{content_name_tabs content_form_editor}
        index.franchise_home_content_content_form_bottom.concat %w{content_form_buttons mini_content_tab_javascript}
        index.below_content.concat %w{tab_javascript}
        index.right_side.concat %w{}
      end
      franchise_home_content.update = franchise_home_content.show
    end
  end

  def load_default_franchise_profiles_regions
    returning OpenStruct.new do |franchise_profiles|
      franchise_profiles.edit = Bionic::AdminInterface::RegionSet.new do |edit|
        edit.main.concat %w{edit_form}
        edit.form_top.concat %w{edit_errors}
        edit.form.concat %w{edit_profile_fields edit_user_fields}
        edit.form.concat %w{edit_franchise_id edit_consignor edit_volunteer edit_mailing_list}
        edit.profile_fields.concat %w{edit_email edit_email_confirmation edit_first_name edit_last_name}
        edit.profile_fields.concat %w{edit_phone edit_address_1 edit_address_2 edit_city edit_country}
        edit.profile_fields.concat %w{edit_province edit_postal_code edit_how_did_you_fields}
        edit.user_fields.concat %w{edit_login edit_password edit_password_confirmation}
        edit.form_bottom.concat %w{edit_buttons}
        edit.right_side.concat %w{franchise_links}
      end
      franchise_profiles.new = franchise_profiles.edit    
    end    
  end
  
  def load_default_franchises_owner_profile_regions
    returning OpenStruct.new do |franchise_owner_profiles|
      franchise_owner_profiles.edit = Bionic::AdminInterface::RegionSet.new do |edit|
        edit.main.concat %w{edit_form}
        edit.form_top.concat %w{edit_errors}
        edit.form.concat %w{edit_franchise_id edit_profile_id}
        edit.form_bottom.concat %w{edit_buttons}
        edit.right_side.concat %w{}
      end
      franchise_owner_profiles.new = franchise_owner_profiles.edit
    end    
  end

  def load_default_sales_regions
    returning OpenStruct.new do |sales|
      sales.edit = Bionic::AdminInterface::RegionSet.new do |edit|
        edit.main.concat %w{edit_form}
        edit.form_top.concat %w{edit_errors}
        edit.form.concat %w{edit_franchise_id edit_sale_season_id edit_start_date edit_end_date edit_tentative_date}
        edit.form.concat %w{edit_facility_title edit_address_description edit_sale_address edit_sale_city edit_sale_state edit_sale_zip_code edit_has_online_sale}
        edit.form.concat %w{edit_online_start_date edit_first_discount_start_time edit_second_discount_start_time edit_online_end_date edit_online_dropoff_date }
        edit.form.concat %w{edit_online_pickup_date edit_tax_rate edit_sale_percentage edit_sale_advert_cost}
        edit.form_bottom.concat %w{edit_buttons}
        edit.right_side.concat %w{}
      end
      sales.new = sales.edit
      sales.show = Bionic::AdminInterface::RegionSet.new do |show|
        show.above_content.concat %w{action_list}
        show.tab_header.concat %w{sale_info_tab_header sale_pdf_tab_header}
        show.tabs.concat %w{sale_info_tab sale_pdf_tab}
        show.action_row.concat %w{index_form}
        show.index_form_top.concat %w{edit_index_errors}
        show.index_form.concat %w{edit_pdf_file}
        show.index_form_bottom.concat %w{edit_index_buttons}
        show.below_content.concat %w{tab_javascript}
        show.right_side.concat %w{sale_links}
      end
      sales.consignors = Bionic::AdminInterface::RegionSet.new do |consignors|
        consignors.before_list.concat %w{}
        consignors.top.concat %w{pagination_counts}
        consignors.list_headers.concat %w{consignor_number_column_header active_items_column_header sort_column_header name_column_header email_column_header}
        consignors.list_headers.concat %w{phone_column_header sale_percentage_column_header fee_adjustment_column_header est_advert_cost_column_header action_column_header}
        consignors.list_data.concat %w{consignor_number_column active_items_column sort_column name_column email_column}
        consignors.list_data.concat %w{phone_column sale_percentage_column fee_adjustment_column est_advert_cost_column actions_column}
        consignors.after_list.concat %w{pagination_links}
        consignors.action_row.concat %w{sales_path}
        consignors.right_side.concat %w{sale_links user_sort}
      end
      sales.consignors_history = Bionic::AdminInterface::RegionSet.new do |consignors|
        consignors.before_list.concat %w{}
        consignors.top.concat %w{pagination_counts}
        consignors.list_headers.concat %w{number_column_header sort_group_column_header first_name_column_header}
        consignors.list_headers.concat %w{last_name_column_header created_at_column_header last_consign_date_column_header} 
        consignors.list_headers.concat %w{number_events_column_header life_time_proceeds_column_header}
        consignors.list_headers.concat %w{last_sale_proceeds_column_header lifetime_items_column_header last_sale_items_column_header}
        consignors.list_headers.concat %w{unsold_items_column_header unsold_value_column_header inactive_items_column_header}
        consignors.list_data.concat %w{number_column sort_group_column first_name_column last_name_column created_at_column}
        consignors.list_data.concat %w{last_consign_date_column number_events_column life_time_proceeds_column last_sale_proceeds_column}
        consignors.list_data.concat %w{lifetime_items_column last_sale_items_column unsold_items_column unsold_value_column inactive_items_column}
        consignors.after_list.concat %w{pagination_links}
        consignors.action_row.concat %w{sales_path}
        consignors.right_side.concat %w{sale_links user_history_sort}
      end
      sales.online_sales_report = Bionic::AdminInterface::RegionSet.new do |report|
        report.before_list.concat %w{}
        report.top.concat %w{pagination_counts}
        report.list_headers.concat %w{buyer_name_column_header sort_column_column_header}
        report.list_headers.concat %w{ item_number_column_header item_name_column_header} 
        report.list_headers.concat %w{item_price_column_header item_sales_tax_column_header}
        report.list_headers.concat %w{item_total_price_column_header consignor_number_column_header seller_name_column_header}
        report.list_data.concat %w{buyer_name_column sort_column_column item_number_column}
        report.list_data.concat %w{item_name_column item_price_column item_sales_tax_column item_total_price_column}
        report.list_data.concat %w{consignor_number_column seller_name_column }
        report.after_list.concat %w{pagination_links}
        report.action_row.concat %w{sales_path}
        report.right_side.concat %w{sale_links}
      end
      sales.volunteers = Bionic::AdminInterface::RegionSet.new do |volunteers|
        volunteers.before_list.concat %w{}
        volunteers.top.concat %w{pagination_counts}
        volunteers.list_headers.concat %w{consignor_column_header account_number_column_header items_coming_column_header}
        volunteers.list_headers.concat %w{name_column_header email_column_header phone_column_header}
        volunteers.list_headers.concat %w{job_title_column_header date_time_column_header action_column_header}
        volunteers.list_data.concat %w{consignor_column account_number_column items_coming_column name_column}
        volunteers.list_data.concat %w{email_column phone_column job_title_column date_time_column actions_column}
        volunteers.after_list.concat %w{pagination_links}
        volunteers.action_row.concat %w{sales_path}
        volunteers.right_side.concat %w{sale_links}
      end
      sales.volunteers_history = Bionic::AdminInterface::RegionSet.new do |volunteers|
        volunteers.before_list.concat %w{}
        volunteers.top.concat %w{pagination_counts}
        volunteers.list_headers.concat %w{number_column_header name_column_header email_column_header}
        volunteers.list_headers.concat %w{phone_column_header created_at_column_header last_volunteer_date_column_header} 
        volunteers.list_headers.concat %w{last_sale_jobs_column_header lifetime_jobs_column_header number_events_column_header}
        volunteers.list_data.concat %w{number_column name_column email_column phone_column created_at_column}
        volunteers.list_data.concat %w{last_volunteer_date_column last_sale_jobs_column lifetime_jobs_column number_events_column}
        volunteers.after_list.concat %w{pagination_links}
        volunteers.action_row.concat %w{sales_path}
        volunteers.right_side.concat %w{sale_links}
      end
      sales.rewards_available = Bionic::AdminInterface::RegionSet.new do |rewards_available|
        rewards_available.before_list.concat %w{}
        rewards_available.list_headers.concat %w{rewards_number_column_header name_column_header sale_season_column_header amount_purchased_column_header}
        rewards_available.list_headers.concat %w{amount_earned_column_header awards_applied_column_header awards_available_column_header}
        rewards_available.list_data.concat %w{rewards_number_column name_column sale_season_column amount_purchased_column}
        rewards_available.list_data.concat %w{amount_earned_column awards_applied_column awards_available_column}
        rewards_available.after_list.concat %w{pagination_links}
        rewards_available.action_row.concat %w{sales_path}
        rewards_available.right_side.concat %w{sale_links}
      end
      sales.rewards_manager = Bionic::AdminInterface::RegionSet.new do |rewards_manager|
        rewards_manager.top.concat %w{pagination_counts}
        rewards_manager.list_headers.concat %w{rewards_number_column_header name_column_header email_column_header}
        rewards_manager.list_headers.concat %w{amount_earned_column_header awards_applied_column_header action_column_header}
        rewards_manager.list_data.concat %w{rewards_number_column name_column email_column}
        rewards_manager.list_data.concat %w{amount_earned_column awards_applied_column actions_column}
        rewards_manager.after_list.concat %w{pagination_links}
        rewards_manager.action_row.concat %w{sales_path}
        rewards_manager.right_side.concat %w{sale_links rewards_search}
      end
      sales.rewards_list = sales.rewards_manager
      sales.rewards_history = Bionic::AdminInterface::RegionSet.new do |rewards_history|
        rewards_history.before_list.concat %w{}
        rewards_history.list_headers.concat %w{date_column_header rewards_number_column_header name_column_header}
        rewards_history.list_headers.concat %w{email_column_header amount_applied_column_header action_column_header}
        rewards_history.list_data.concat %w{date_column rewards_number_column name_column}
        rewards_history.list_data.concat %w{email_column amount_applied_column actions_column}
        rewards_history.after_list.concat %w{pagination_links}
        rewards_history.action_row.concat %w{sales_path}
        rewards_history.right_side.concat %w{sale_links}
      end
      sales.apply_reward = sales.rewards_manager
      sales.reports = Bionic::AdminInterface::RegionSet.new do |reports|
        reports.above_content.concat %w{action_list}
        reports.before_list.concat %w{}
        reports.action_row.concat %w{full_breakdown_path}
        reports.bottom.concat %w{}
        reports.right_side.concat %w{report_links}
      end
      sales.sales_export = Bionic::AdminInterface::RegionSet.new do |sales_export|
        sales_export.above_content.concat %w{action_list}
        sales_export.action_row.concat %w{download_path}
        sales_export.bottom.concat %w{}
        sales_export.right_side.concat %w{report_links}
      end
      sales.checks_export = sales.sales_export
      sales.promo_codes = Bionic::AdminInterface::RegionSet.new do |promo_codes|
        promo_codes.above_content.concat %w{action_list}
        promo_codes.tab_header.concat %w{promo_codes_tab_header}
        promo_codes.tabs.concat %w{promo_codes_tab}
        promo_codes.promo_codes_list_headers.concat %w{promo_code_column_header count_column_header actions_column_header}
        promo_codes.promo_codes_list_data.concat %w{promo_code_column count_column actions_column}
        promo_codes.below_content.concat %w{tab_javascript}
        promo_codes.right_side.concat %w{report_links}
      end
      sales.promo_code_report = Bionic::AdminInterface::RegionSet.new do |promo_code_profile|
        promo_code_profile.above_content.concat %w{action_list}
        promo_code_profile.before_list.concat %w{}
        promo_code_profile.list_headers.concat %w{consignor_number_column_header name_column_header email_column_header}
        promo_code_profile.list_data.concat %w{consignor_number_column name_column email_column}
        promo_code_profile.after_list.concat %w{pagination_links}
        promo_code_profile.action_row.concat %w{sales_path}
        promo_code_profile.right_side.concat %w{report_links}
      end
      sales.expired_pay_pal_orders = Bionic::AdminInterface::RegionSet.new do |orders|
        orders.before_list.concat %w{}
        orders.top.concat %w{pagination_counts}
        orders.list_headers.concat %w{date_column_header consignor_number_column_header name_column_header }
        orders.list_headers.concat %w{item_descriptions_column_header amount_column_header actions_column_header}
        orders.list_data.concat %w{date_column consignor_number_column name_column}
        orders.list_data.concat %w{ item_descriptions_column amount_column actions_column}
        orders.after_list.concat %w{pagination_links}
        orders.action_row.concat %w{sales_path}
        orders.right_side.concat %w{sale_links}
      end
    end    
  end

  def load_default_franchise_photos_regions
    returning OpenStruct.new do |franchise_photo|
      franchise_photo.index = Bionic::AdminInterface::RegionSet.new do |index|
        index.before_list.concat %w{}
        index.top.concat %w{pagination_counts}
        index.list_headers.concat %w{sort_order_column_header icon_column_header name_column_header caption_column_header show_on_slider_column_header actions_column_header}
        index.list_data.concat %w{sort_order_column icon_column name_column caption_column show_on_slider_column actions_column}
        index.after_list.concat %w{pagination_links}
        index.action_row.concat %w{index_form}
        index.index_form_top.concat %w{edit_index_errors}
        index.index_form.concat %w{edit_index_filename edit_index_caption edit_franchise_id edit_show_on_slider edit_sort_order}
        index.index_form_bottom.concat %w{edit_index_buttons}
        index.bottom.concat %w{}
        index.right_side.concat %w{franchise_links}
      end
      franchise_photo.new = Bionic::AdminInterface::RegionSet.new do |new|
        new.main.concat %w{index_form}
        new.index_form_top.concat %w{edit_index_errors}
        new.index_form.concat %w{edit_index_caption edit_franchise_id}
        new.site_asset_fields.concat %w{edit_index_filename}
        new.index_form_bottom.concat %w{edit_index_buttons}
        new.bottom.concat %w{}
        new.right_side.concat %w{franchise_links}
      end
      franchise_photo.edit = Bionic::AdminInterface::RegionSet.new do |edit|
        edit.main.concat %w{edit_form}
        edit.form_top.concat %w{edit_errors}
        edit.form.concat %w{edit_index_filename edit_index_caption edit_franchise_id edit_show_on_slider edit_sort_order}
        edit.form_bottom.concat %w{edit_buttons}
        edit.right_side.concat %w{franchise_links}
      end
    end
  end

  def load_default_franchise_rewards_adjustments_regions
    returning OpenStruct.new do |franchise_rewards_adjustment|
      franchise_rewards_adjustment.index = Bionic::AdminInterface::RegionSet.new do |index|
        index.before_list.concat %w{}
        index.top.concat %w{pagination_counts}
        index.list_headers.concat %w{rewards_number_column_header name_column_header amount_column_header comment_column_header actions_column_header}
        index.list_data.concat %w{rewards_number_column name_column amount_column comment_column actions_column}
        index.after_list.concat %w{pagination_links}
        index.action_row.concat %w{back_to_franchise_link}
        index.right_side.concat %w{franchise_links}
      end
      franchise_rewards_adjustment.edit = Bionic::AdminInterface::RegionSet.new do |edit|
        edit.main.concat %w{edit_form}
        edit.form_top.concat %w{edit_errors}
        edit.form.concat %w{edit_franchise_id edit_rewards_number edit_rewards_number_confirmation edit_amount edit_comment}
        edit.form_bottom.concat %w{edit_buttons}
        edit.right_side.concat %w{}
      end
      franchise_rewards_adjustment.new = franchise_rewards_adjustment.edit
    end
  end

  def load_default_sale_consignor_times_regions
    returning OpenStruct.new do |sale_consignor_times|
      sale_consignor_times.index = Bionic::AdminInterface::RegionSet.new do |index|
        index.top.concat %w{pagination_counts}
        index.list_headers.concat %w{date_column_header times_column_header items_column_header}
        index.list_headers.concat %w{spots_column_header actions_column_header}
        index.list_data.concat %w{date_column times_column items_column spots_column actions_column}
        index.after_list.concat %w{pagination_links}
        index.action_row.concat %w{new_consignor_time}
        index.bottom.concat %w{}
        index.right_side.concat %w{sale_links}
      end
      sale_consignor_times.show = Bionic::AdminInterface::RegionSet.new do |show|
        show.above_content.concat %w{action_list}
        show.tab_header.concat %w{consignors_tab_header}
        show.tabs.concat %w{consignors_tab}
        show.consignors_list_headers.concat %w{consignor_number_column_header items_coming_column_header consignor_name_column_header}
        show.consignors_list_headers.concat %w{consignor_email_column_header consignor_phone_column_header sale_advertisement_cost_column_header}
        show.consignors_list_headers.concat %w{sale_percentage_column_header promo_code_column_header actions_column_header}
        show.consignors_list_data.concat %w{consignor_number_column items_coming_column consignor_name_column consignor_email_column}
        show.consignors_list_data.concat %w{consignor_phone_column sale_advertisement_cost_column sale_percentage_column promo_code_column actions_column}
        show.after_list.concat %w{pagination_links}
        show.action_row.concat %w{index_form}
        show.index_form_top.concat %w{edit_index_errors}
        show.index_form.concat %w{edit_consignor_profile_id edit_consignor_time_id}
        show.index_form_bottom.concat %w{edit_index_buttons}
        show.below_content.concat %w{tab_javascript}
        show.right_side.concat %w{sale_links}
      end
      sale_consignor_times.edit = Bionic::AdminInterface::RegionSet.new do |edit|
        edit.main.concat %w{edit_form}
        edit.form_top.concat %w{edit_errors}
        edit.form.concat %w{edit_sale_id edit_date edit_start_time edit_end_time edit_number_of_spots}
        edit.form_bottom.concat %w{edit_buttons}
        edit.right_side.concat %w{}
      end
      sale_consignor_times.new = sale_consignor_times.edit
    end
  end

  def load_default_business_partners_regions
    returning OpenStruct.new do |business_partners|
      business_partners.index = Bionic::AdminInterface::RegionSet.new do |index|
        index.list_headers.concat %w{sort_column_header title_column_header url_column_header}
        index.list_headers.concat %w{description_column_header actions_column_header}
        index.list_data.concat %w{sort_column title_column url_column description_column actions_column}
        index.action_row.concat %w{new_business_partner}
        index.right_side.concat %w{sale_links}
      end
      business_partners.edit = Bionic::AdminInterface::RegionSet.new do |edit|
        edit.main.concat %w{edit_form}
        edit.form_top.concat %w{edit_errors}
        edit.form.concat %w{edit_sale_id edit_title edit_url edit_description edit_sort_index}
        edit.site_asset_fields.concat %w{edit_filename}
        edit.form_bottom.concat %w{edit_buttons}
        edit.right_side.concat %w{}
      end
      business_partners.new = business_partners.edit
    end
  end

  def load_default_sale_volunteer_times_regions
    returning OpenStruct.new do |sale_volunteer_times|
      sale_volunteer_times.index = Bionic::AdminInterface::RegionSet.new do |index|
        index.top.concat %w{pagination_counts}
        index.list_headers.concat %w{date_column_header times_column_header job_title_column_header}
        index.list_headers.concat %w{job_description_column_header spots_column_header draft_column_header actions_column_header}
        index.list_data.concat %w{date_column times_column job_title_column job_description_column spots_column draft_column actions_column}
        index.after_list.concat %w{pagination_links}
        index.action_row.concat %w{new_volunteer_time}
        index.bottom.concat %w{}
        index.right_side.concat %w{sale_links}
      end
      sale_volunteer_times.show = Bionic::AdminInterface::RegionSet.new do |show|
        show.above_content.concat %w{action_list}
        show.tab_header.concat %w{volunteers_tab_header}
        show.tabs.concat %w{volunteers_tab}
        show.volunteers_list_headers.concat %w{volunteer_name_column_header volunteer_email_column_header volunteer_phone_column_header actions_column_header}
        show.volunteers_list_data.concat %w{volunteer_name_column volunteer_email_column volunteer_phone_column actions_column}
        show.after_list.concat %w{pagination_links}
        show.action_row.concat %w{index_form}
        show.index_form_top.concat %w{edit_index_errors}
        show.index_form.concat %w{edit_volunteer_profile_id edit_volunteer_time_id}
        show.index_form_bottom.concat %w{edit_index_buttons}
        show.below_content.concat %w{tab_javascript}
        show.right_side.concat %w{sale_links}
      end
      sale_volunteer_times.edit = Bionic::AdminInterface::RegionSet.new do |edit|
        edit.main.concat %w{edit_form}
        edit.form_top.concat %w{edit_errors}
        edit.form.concat %w{edit_sale_id edit_date edit_job_type edit_start_time edit_end_time edit_job_title edit_job_description edit_number_of_spots edit_draft}
        edit.form_bottom.concat %w{edit_buttons}
        edit.right_side.concat %w{}
      end
      sale_volunteer_times.new = sale_volunteer_times.edit
    end
  end

  def load_default_sale_consignor_sign_ups_regions
    returning OpenStruct.new do |sale_consignor_sign_ups|    
      sale_consignor_sign_ups.edit = Bionic::AdminInterface::RegionSet.new do |edit|
        edit.main.concat %w{edit_form}
        edit.form_top.concat %w{edit_errors}
        edit.form.concat %w{edit_consignor_profile_id edit_consignor_time_id edit_advertisement_cost}
        edit.form.concat %w{edit_check_adjustment edit_sale_percentage edit_promo_code edit_comments}
        edit.form_bottom.concat %w{edit_buttons}
        edit.right_side.concat %w{}
      end
      sale_consignor_sign_ups.new = sale_consignor_sign_ups.edit
    end
  end

  def load_default_sale_volunteer_sign_ups_regions
    returning OpenStruct.new do |sale_volunteer_sign_ups|    
      sale_volunteer_sign_ups.edit = Bionic::AdminInterface::RegionSet.new do |edit|
        edit.main.concat %w{edit_form}
        edit.form_top.concat %w{edit_errors}
        edit.form.concat %w{edit_volunteer_profile_id edit_volunteer_time_id edit_comments}
        edit.form_bottom.concat %w{edit_buttons}
        edit.right_side.concat %w{}
      end
      sale_volunteer_sign_ups.new = sale_volunteer_sign_ups.edit
    end
  end

  def load_default_transaction_imports_regions
    returning OpenStruct.new do |transaction_imports|
      transaction_imports.index = Bionic::AdminInterface::RegionSet.new do |index|
        index.before_list.concat %w{}
        index.top.concat %w{pagination_counts}
        index.list_headers.concat %w{report_dates_column_header report_number_column_header report_name_column_header}
        index.list_headers.concat %w{extra_income_column_header actions_column_header}
        index.list_data.concat %w{report_dates_column report_number_column report_name_column extra_income_column actions_column}
        index.after_list.concat %w{pagination_links}
        index.action_row.concat %w{index_form}
        index.index_form_top.concat %w{edit_index_errors}
        index.index_form.concat %w{edit_sale_id edit_index_report_date edit_index_extra_income}
        index.site_asset_fields.concat %w{edit_index_filename}
        index.index_form_bottom.concat %w{edit_index_buttons}
        index.bottom.concat %w{}
        index.right_side.concat %w{}
      end
      transaction_imports.log = Bionic::AdminInterface::RegionSet.new do |log|
        log.before_list.concat %w{}
        log.list_headers.concat %w{item_number_column_header consignor_number_column_header}
        log.list_headers.concat %w{consignor_name_column_header error_message_column_header}
        log.list_data.concat %w{item_number_column consignor_number_column consignor_name_column error_message_column}
        log.action_row.concat %w{transaction_import_path}
        log.right_side.concat %w{}
      end
      transaction_imports.edit = Bionic::AdminInterface::RegionSet.new do |edit|
        edit.main.concat %w{index_form}
        edit.form_top.concat %w{edit_index_errors}
        edit.index_form.concat %w{edit_sale_id edit_index_report_date edit_index_extra_income}
        edit.site_asset_fields.concat %w{edit_index_filename}
        edit.index_form_bottom.concat %w{edit_index_buttons}
        edit.right_side.concat %w{}
      end
      transaction_imports.new = transaction_imports.edit
    end
  end
  
  def load_default_rewards_imports_regions
    returning OpenStruct.new do |rewards_imports|
      rewards_imports.index = Bionic::AdminInterface::RegionSet.new do |index|
        index.above_content.concat %w{action_list}
        index.before_list.concat %w{}
        index.list_headers.concat %w{report_dates_column_header report_name_column_header actions_column_header}
        index.list_data.concat %w{report_dates_column report_name_column actions_column}
        index.action_row.concat %w{rewards_import_path}
        index.bottom.concat %w{}
        index.right_side.concat %w{}
      end
      rewards_imports.edit = Bionic::AdminInterface::RegionSet.new do |edit|
        edit.main.concat %w{index_form}
        edit.form_top.concat %w{edit_index_errors}
        edit.index_form.concat %w{edit_sale_id edit_index_report_date}
        edit.site_asset_fields.concat %w{edit_index_filename}
        edit.index_form_bottom.concat %w{edit_index_buttons}
        edit.right_side.concat %w{}
      end
      rewards_imports.new = rewards_imports.edit
    end
  end

  def load_default_franchise_file_category_regions
    returning OpenStruct.new do |file_category|
      file_category.index = Bionic::AdminInterface::RegionSet.new do |index|
        index.before_list.concat %w{}
        index.top.concat %w{pagination_counts}
        index.list_headers.concat %w{category_title_header actions_column_header}
        index.list_data.concat %w{title_column actions_column}
        index.after_list.concat %w{pagination_links}
        index.action_row.concat %w{edit_form}
        index.form_top.concat %w{edit_form_errors}
        index.form.concat %w{edit_category_title}
        index.form_bottom.concat %w{edit_index_buttons}
        index.bottom.concat %w{}
        index.right_side.concat %w{}
      end
      file_category.show = Bionic::AdminInterface::RegionSet.new do |show|
        show.before_list.concat %w{}
        show.list_headers.concat %w{file_name_column_header description_column_header actions_column_header}
        show.list_data.concat %w{file_name_column description_column actions_column}
        show.after_list.concat %w{pagination_links}
        show.action_row.concat %w{index_form}
        show.index_form_top.concat %w{edit_index_errors}
        show.index_form.concat %w{edit_description edit_franchise_file_category_id}
        show.site_asset_fields.concat %w{edit_index_filename edit_index_display_name}
        show.index_form_bottom.concat %w{edit_index_buttons}
        show.bottom.concat %w{}
        show.right_side.concat %w{}
      end
      file_category.edit = Bionic::AdminInterface::RegionSet.new do |edit|
        edit.main.concat %w{edit_form}
        edit.form_top.concat %w{edit_form_errors}
        edit.form.concat %w{edit_category_title}
        edit.form_bottom.concat %w{edit_index_buttons}
        edit.right_side.concat %w{}
      end
      file_category.new = file_category.edit
    end
  end

  def load_default_franchise_file_regions
    returning OpenStruct.new do |franchise_file|
      franchise_file.new = Bionic::AdminInterface::RegionSet.new do |new|
        new.main.concat %w{index_form}
        new.form_top.concat %w{edit_errors}
        new.index_form.concat %w{edit_description edit_franchise_file_category_id}
        new.site_asset_fields.concat %w{edit_index_filename edit_index_display_name}
        new.index_form_bottom.concat %w{edit_index_buttons}
        new.right_side.concat %w{}
      end
    end
  end

  def load_default_sale_seasons_regions
    returning OpenStruct.new do |sale_seasons|
      sale_seasons.index = Bionic::AdminInterface::RegionSet.new do |index|
        index.list_headers.concat %w{season_name_column_header dates_column_header}
        index.list_headers.concat %w{number_of_sales_column_header actions_column_header}
        index.list_data.concat %w{season_name_column season_dates_column number_of_sales_column actions_column}
        index.after_list.concat %w{pagination_links}
        index.action_row.concat %w{new_sale_season}
        index.bottom.concat %w{}
        index.right_side.concat %w{}
      end
      sale_seasons.show = Bionic::AdminInterface::RegionSet.new do |show|
        show.above_content.concat %w{action_list}
        show.tab_header.concat %w{season_sales_tab_header}
        show.tabs.concat %w{season_sales_tab}
        show.franchise_sale_list_headers.concat %w{franchise_column_header sale_dates_column_header sale_address_column_header active_sale_column_header actions_column_header}
        show.franchise_sale_list_data.concat %w{franchise_column sale_dates_column sale_address_column active_sale_column actions_column}
        show.season_sales_action_row.concat %w{back_to_seasons}
        show.after_list.concat %w{pagination_links}
        show.below_content.concat %w{tab_javascript}
        show.right_side.concat %w{sale_season_links}
      end
      sale_seasons.reports = Bionic::AdminInterface::RegionSet.new do |reports|
        reports.above_content.concat %w{action_list}
        reports.tab_header.concat %w{season_financials_tab_header}
        reports.tabs.concat %w{season_financials_tab}
        reports.season_sales_list_headers.concat %w{franchise_column_header sale_dates_column_header transactions_column_header sale_revenues_column_header consignor_fees_column_header revenues_column_header profit_column_header}
        reports.season_sales_list_data.concat %w{franchise_column sale_dates_column transactions_column sale_revenues_column consignor_fees_column revenues_column profit_column}
        reports.season_sales_action_row.concat %w{back_to_season}
        reports.after_list.concat %w{pagination_links}
        reports.below_content.concat %w{tab_javascript}
        reports.right_side.concat %w{sale_season_links}
      end
      sale_seasons.edit = Bionic::AdminInterface::RegionSet.new do |edit|
        edit.main.concat %w{edit_form}
        edit.form_top.concat %w{edit_errors}
        edit.form.concat %w{edit_sale_season_name edit_start_date edit_end_date}
        edit.form_bottom.concat %w{edit_buttons}
        edit.right_side.concat %w{}
      end
      sale_seasons.new = sale_seasons.edit
    end
  end

  def load_default_consignor_inventories_regions
    returning OpenStruct.new do |consignor_inventories|
      consignor_inventories.index = Bionic::AdminInterface::RegionSet.new do |index|
        index.before_list.concat %w{}
        index.top.concat %w{pagination_counts}
        index.list_headers.concat %w{date_column_header item_number_column_header consignor_column_header item_description_column_header}
        index.list_headers.concat %w{sale_price_column_header total_price_column_header actions_column_header}
        index.list_data.concat %w{date_column item_number_column consignor_column item_description_column}
        index.list_data.concat %w{sale_price_column total_price_column actions_column}
        index.after_list.concat %w{pagination_links}
        index.action_row.concat %w{back_to_sale_link}
        index.bottom.concat %w{}
        index.right_side.concat %w{search}
      end
      consignor_inventories.items_coming = Bionic::AdminInterface::RegionSet.new do |items_coming|
        items_coming.before_list.concat %w{}
        items_coming.top.concat %w{pagination_counts}
        items_coming.list_headers.concat %w{consignor_number_column_header consignor_column_header item_number_column_header item_description_column_header size_column_header}
        items_coming.list_headers.concat %w{price_column_header donate_column_header discount_column_header featured_column_header actions_column_header}
        items_coming.list_data.concat %w{consignor_number_column consignor_column item_number_column item_description_column}
        items_coming.list_data.concat %w{size_column price_column donate_column discount_column featured_column actions_column}
        items_coming.after_list.concat %w{pagination_links}
        items_coming.action_row.concat %w{back_to_sale_link}
        items_coming.bottom.concat %w{}
        items_coming.right_side.concat %w{search}
      end
      consignor_inventories.items_selling_online = Bionic::AdminInterface::RegionSet.new do |items_coming|
        items_coming.before_list.concat %w{}
        items_coming.top.concat %w{pagination_counts}
        items_coming.list_headers.concat %w{consignor_number_column_header consignor_column_header item_number_column_header item_description_column_header category_column_header}
        items_coming.list_headers.concat %w{size_column_header price_column_header donate_column_header discount_column_header picture_column_header actions_column_header}
        items_coming.list_data.concat %w{consignor_number_column consignor_column item_number_column item_description_column category_column}
        items_coming.list_data.concat %w{size_column price_column donate_column discount_column picture_column actions_column}
        items_coming.after_list.concat %w{pagination_links}
        items_coming.action_row.concat %w{back_to_sale_link}
        items_coming.bottom.concat %w{}
        items_coming.right_side.concat %w{search}
      end
      consignor_inventories.edit = Bionic::AdminInterface::RegionSet.new do |edit|
        edit.main.concat %w{edit_form}
        edit.form_top.concat %w{edit_errors}
        edit.form.concat %w{edit_featured_item edit_category edit_sub_category edit_price edit_description }
        edit.form.concat %w{edit_size edit_discount edit_donate edit_item_coming edit_additional_information}
        edit.featured_photo_fields.concat %w{edit_filename}
        edit.form_bottom.concat %w{edit_buttons}
        edit.right_side.concat %w{}
      end
      consignor_inventories.show = Bionic::AdminInterface::RegionSet.new do |show|
        show.above_content.concat %w{action_list}
        show.tab_header.concat %w{items_tab_header}
        show.tabs.concat %w{items_tab}
        show.featured_photos_list_headers.concat %w{rotate_counter_clockwise_column_header photo_column_header}
        show.featured_photos_list_headers.concat %w{rotate_clockwise_column_header actions_column_header}
        show.featured_photos_list_data.concat %w{rotate_counter_clockwise_column photo_column}
        show.featured_photos_list_data.concat %w{rotate_clockwise_column actions_column}
        show.after_list.concat %w{}
        show.action_row.concat %w{index_form}
        show.index_form_top.concat %w{edit_index_errors}
        show.index_form.concat %w{edit_asset edit_item_id}
        show.index_form_bottom.concat %w{edit_index_buttons}
        show.below_content.concat %w{tab_javascript}
        show.right_side.concat %w{sale_links}
      end
    end
  end

  def load_default_kids_emails_regions
    returning OpenStruct.new do |kids_emails|
      kids_emails.index = Bionic::AdminInterface::RegionSet.new do |index|
        index.before_list.concat %w{}
        index.top.concat %w{pagination_counts}
        index.list_headers.concat %w{date_column_header subject_column_header recipients_column_header}
        index.list_headers.concat %w{email_count_column_header actions_column_header}
        index.list_data.concat %w{date_column subject_column recipients_column email_count_column actions_column}
        index.after_list.concat %w{pagination_links}
        index.action_row.concat %w{back_to_franchise_link}
        index.bottom.concat %w{}
        index.right_side.concat %w{franchise_links}
      end
      kids_emails.edit = Bionic::AdminInterface::RegionSet.new do |edit|
        edit.main.concat %w{edit_form}
        edit.form_top.concat %w{edit_errors}
        edit.form.concat %w{edit_franchise_id edit_recipients edit_subject edit_email_html_body edit_email_text_body edit_test_email edit_schedule}
        edit.form_bottom.concat %w{edit_buttons}
        edit.right_side.concat %w{}
        edit.below_content.concat %w{html_content_javascript}
      end
      kids_emails.new = kids_emails.edit
      kids_emails.email_volunteers_in_job = kids_emails.edit
    end
  end

  def load_default_check_printers_regions
    returning OpenStruct.new do |check_printers|
      check_printers.edit = Bionic::AdminInterface::RegionSet.new do |edit|
        edit.main.concat %w{edit_form}
        edit.form_top.concat %w{edit_errors}
        edit.form.concat %w{edit_owner_name edit_company_name edit_address edit_address_2 edit_routing_number}
        edit.form.concat %w{edit_account_number edit_transit_number edit_starting_check_number edit_bank_name}
        edit.form_bottom.concat %w{edit_buttons}
        edit.right_side.concat %w{}
        edit.below_content.concat %w{sample_check}
      end
      check_printers.new = check_printers.edit
      check_printers.index = check_printers.edit
    end
  end

end