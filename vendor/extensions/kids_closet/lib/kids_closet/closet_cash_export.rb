module KidsCloset

  class ClosetCashExport < Struct.new(:franchise_id, :email)

    def perform
      Site.current_site_id = 1
      franchise = Franchise.find(franchise_id)
      available_profiles = franchise.rewards_profiles

      FasterCSV.open(franchise.closet_cash_export_path, "w") do |csv|
        csv << ['Rewards Number', 'Last Name', 'First Name', 'Phone #', 'Amount Available']
        total_available = 0
        for rewards_profile in available_profiles
          if rewards_profile.profile.nil?
            rewards_earned = rewards_profile.single_card_rewards_for_franchise(franchise)
            amount_redeamed = RewardsEarning.earnings_by_card(rewards_profile, franchise_id)
            amount_available = rewards_earned - amount_redeamed
            if amount_available > 0
              csv << [rewards_profile.rewards_number, "", "", "", amount_available]
            end
            total_available += amount_available
          else
            rewards_earned = rewards_profile.rewards_for_franchise(franchise)
            amount_redeamed = RewardsEarning.earnings_by_profile_and_franchise(rewards_profile.profile, franchise_id)
            if rewards_earned > amount_redeamed
              csv << [rewards_profile.rewards_number, rewards_profile.profile.last_name, rewards_profile.profile.first_name, rewards_profile.profile.phone, rewards_earned - amount_redeamed]
            end
            total_available += rewards_earned - amount_redeamed
          end
        end
        csv << ['Total rewards available for redemption: ', "", "", "", "$#{total_available}"]
      end
      email_to_deliver = KidsMailer.create_general_mass_email(nil, email, nil, "Closet Cash Rewards Available Export", franchise.closet_cash_export_notification, "", "", "ssmitka@kidscloset.biz")
      KidsMailer.deliver(email_to_deliver)
    end

  end

end