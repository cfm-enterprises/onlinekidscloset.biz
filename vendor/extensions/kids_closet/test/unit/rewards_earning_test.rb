require File.dirname(__FILE__) + '/../test_helper'

class RewardsEarningTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  fixtures :rewards_earnings, :franchises, :rewards_profiles, :sales
  
  test "check fixtures got loaded" do
    assert_equal 3, RewardsEarning.count
  end

  test "rewards earning must belong to a sale" do
    rewards_earning = RewardsEarning.new
    rewards_earning.rewards_profile = rewards_profiles(:rewards_profile_1)
    rewards_earning.amount_applied = 5
    assert !rewards_earning.save, "rewards earning saved without a sale"
    rewards_earning.sale = sales(:florida_current)
    calculate_sale_financials
    assert rewards_earning.save, "adding sale did not save the rewards earning"
  end

  test "rewards earning must belong to a rewards profile" do
    rewards_earning = RewardsEarning.new
    rewards_earning.amount_applied = 5
    rewards_earning.sale = sales(:florida_current)
    calculate_sale_financials
    assert !rewards_earning.save, "rewards earning saved without a rewards profile"
    rewards_earning.rewards_profile = rewards_profiles(:rewards_profile_1)
    assert rewards_earning.save, "adding rewards profile did not save the rewards earning"
  end

  test "rewards earning must have an amount applied" do
    rewards_earning = RewardsEarning.new
    rewards_earning.sale = sales(:florida_current)
    calculate_sale_financials
    rewards_earning.rewards_profile = rewards_profiles(:rewards_profile_1)
    assert !rewards_earning.save, "rewards earning saved without an amount applied"
    rewards_earning.amount_applied = 5
    assert rewards_earning.save, "adding amount applied did not save the rewards earning"
  end

  test "rewards earning must have an amount applied that is a number" do
    rewards_earning = RewardsEarning.new
    rewards_earning.sale = sales(:florida_current)
    calculate_sale_financials
    rewards_earning.rewards_profile = rewards_profiles(:rewards_profile_1)
    rewards_earning.amount_applied = "abcd"
    assert !rewards_earning.save, "rewards earning saved with invalid amount applied"
    rewards_earning.amount_applied = 5
    assert rewards_earning.save, "correcting amount did not the rewards earning"
  end

  test "rewards earning must have an amount applied that is a number 2" do
    rewards_earning = RewardsEarning.new
    rewards_earning.sale = sales(:florida_current)
    calculate_sale_financials
    rewards_earning.rewards_profile = rewards_profiles(:rewards_profile_1)
    rewards_earning.amount_applied = "1..111"
    assert !rewards_earning.save, "rewards earning saved with invalid amount applied"
    rewards_earning.amount_applied = 5
    assert rewards_earning.save, "adding sale did not save the rewards earning"
  end

  test "rewards earning must have an amount applied that is a positive number" do
    rewards_earning = RewardsEarning.new
    rewards_earning.sale = sales(:florida_current)
    calculate_sale_financials
    rewards_earning.rewards_profile = rewards_profiles(:rewards_profile_1)
    rewards_earning.amount_applied = -5
    assert !rewards_earning.save, "rewards earning saved with invalid amount applied"
    rewards_earning.amount_applied = 5
    assert rewards_earning.save, "adding sale did not save the rewards earning"
  end

  test "rewards earning must have an amount applied that is not 0" do
    rewards_earning = RewardsEarning.new
    rewards_earning.sale = sales(:florida_current)
    calculate_sale_financials
    rewards_earning.rewards_profile = rewards_profiles(:rewards_profile_1)
    rewards_earning.amount_applied = 0
    assert !rewards_earning.save, "rewards earning saved with invalid amount applied"
    rewards_earning.amount_applied = 5
    assert rewards_earning.save, "adding sale did not save the rewards earning"
  end

  test "a valid rewards award saves" do
    rewards_earning = RewardsEarning.new
    rewards_earning.sale = sales(:florida_current)
    calculate_sale_financials
    rewards_earning.rewards_profile = rewards_profiles(:rewards_profile_1)
    rewards_earning.amount_applied = 5
    assert rewards_earning.save, "a valid rewards did not save"
  end

  test "a award will not save if the profile has not earned enough money" do
    rewards_earning = RewardsEarning.new
    rewards_earning.sale = sales(:florida_current)
    calculate_sale_financials
    rewards_earning.rewards_profile = rewards_profiles(:rewards_profile_2)
    rewards_earning.amount_applied = 5
    assert !rewards_earning.save, "rewards earning saved with invalid amount applied over the amount earned"
    rewards_earning.rewards_profile = rewards_profiles(:rewards_profile_3)
    assert rewards_earning.save, "changing the rewards profile did not save the sale that should have enough awards available"
  end

  test "earnings for rewards profile 1 kansas franchise" do
    profile = Profile.find(profiles(:reward_1).id)
    assert_equal(RewardsEarning.earnings_by_profile_and_franchise(profile, franchises(:kansas).id), 10, "rewards earnings for reward_1 was not 10")
  end

  test "earnings for rewards profile 1 florida franchise" do
    profile = Profile.find(profiles(:reward_1).id)
    assert_equal(RewardsEarning.earnings_by_profile_and_franchise(profile, franchises(:florida).id), 5, "rewards earnings for reward_1 was not 5")
  end

  test "earnings for rewards profile 2 kansas franchise" do
    profile = Profile.find(profiles(:reward_2).id)
    assert_equal(RewardsEarning.earnings_by_profile_and_franchise(profile, franchises(:kansas).id), 0, "rewards earnings for reward_1 was not 0")
  end

  test "earnings by card for rewards profile 1 kansas franchise" do
    rewards_profile = RewardsProfile.find(rewards_profiles(:rewards_profile_1).id)
    assert_equal(RewardsEarning.earnings_by_card(rewards_profile, franchises(:kansas).id), 5, "rewards profile 1 did not have 5 dollars earnings applied in kansas")
  end  
  
  test "earnings by card for rewards profile 1 florida franchise" do
    rewards_profile = RewardsProfile.find(rewards_profiles(:rewards_profile_1).id)
    assert_equal(RewardsEarning.earnings_by_card(rewards_profile, franchises(:florida).id), 5 , "rewards profile 1 did not have 5 dollars earnigns applied in florida")
  end  
  
  test "earnings by card for rewards profile 3 florida franchise" do
    rewards_profile = RewardsProfile.find(rewards_profiles(:rewards_profile_3).id)
    assert_equal(RewardsEarning.earnings_by_card(rewards_profile, franchises(:kansas).id), 5 , "rewards profile 1 did not have 5 dollars earnigns applied in kansas")
  end  

  test "earnings by card for rewards profile 2 florida franchise" do
    rewards_profile = RewardsProfile.find(rewards_profiles(:rewards_profile_2).id)
    assert_equal(RewardsEarning.earnings_by_card(rewards_profile, franchises(:florida).id), 0, "rewards profile 2 did not have 0 dollars earnings applied in florida")
  end  

  def calculate_sale_financials
    sales = Sale.find(:all)
    for sale in sales
      sale.calculate_financials
    end
  end
end
