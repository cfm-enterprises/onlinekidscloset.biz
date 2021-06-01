require File.dirname(__FILE__) + '/../test_helper'

class RewardsProfileTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  
  fixtures :rewards_profiles, :sales, :consignor_inventories, :franchises, :profiles
  
  test "check fixtures got loaded" do
    assert_equal 5, RewardsProfile.count
  end
  
  test "can't have rewards profile without a rewards number" do
    rewards_profile = RewardsProfile.new
    rewards_profile.profile_id = profiles(:consignor_1).id
    rewards_profile.primary_card = true
    rewards_profile.rewards_number_confirmation = 11111111
    assert !rewards_profile.save, "sale saved without a rewards number"
    rewards_profile.rewards_number = 11111111
    assert rewards_profile.save, "fixing the rewards number did NOT save the rewards profile" 
  end
  
  test "can't have rewards profile with a duplicate rewards number" do
    rewards_profile = RewardsProfile.new
    rewards_profile.profile_id = profiles(:consignor_1).id
    rewards_profile.primary_card = true
    rewards_profile.rewards_number = 10000001
    rewards_profile.rewards_number_confirmation = 10000001
    assert !rewards_profile.save, "sale saved with a duplicate rewards number"
    rewards_profile.rewards_number = 11111111
    rewards_profile.rewards_number_confirmation = 11111111
    assert rewards_profile.save, "fixing the rewards number did NOT save the rewards profile" 
  end

  test "can't have rewards profile with a negative rewards number" do
    rewards_profile = RewardsProfile.new
    rewards_profile.profile_id = profiles(:consignor_1).id
    rewards_profile.primary_card = true
    rewards_profile.rewards_number = -10000001
    rewards_profile.rewards_number_confirmation = -10000001
    assert !rewards_profile.save, "sale saved with a negative a rewards number"
    rewards_profile.rewards_number = 11111111
    rewards_profile.rewards_number_confirmation = 11111111
    assert rewards_profile.save, "fixing the rewards number did NOT save the rewards profile" 
  end

  test "can't have rewards profile with a none confirmed rewards number" do
    rewards_profile = RewardsProfile.new
    rewards_profile.profile_id = profiles(:consignor_1).id
    rewards_profile.primary_card = true
    rewards_profile.rewards_number = 111111112
    rewards_profile.rewards_number_confirmation = 111111111
    assert !rewards_profile.save, "sale saved with wrong confirmation rewards number"
    rewards_profile.rewards_number = 11111111
    rewards_profile.rewards_number_confirmation = 11111111
    assert rewards_profile.save, "fixing the rewards number did NOT save the rewards profile" 
  end

  test "can't have rewards profile with a non numeric rewards number" do
    rewards_profile = RewardsProfile.new
    rewards_profile.profile_id = profiles(:consignor_1).id
    rewards_profile.primary_card = true
    rewards_profile.rewards_number = "abcd"
    rewards_profile.rewards_number_confirmation = "abcd"
    assert !rewards_profile.save, "sale saved without a numeric rewards number"
    rewards_profile.rewards_number = 11111111
    rewards_profile.rewards_number_confirmation = 11111111
    assert rewards_profile.save, "fixing the rewards number did NOT save the rewards profile" 
  end

  test "can't have rewards profile with a non numeric rewards number 2" do
    rewards_profile = RewardsProfile.new
    rewards_profile.profile_id = profiles(:consignor_1).id
    rewards_profile.primary_card = true
    rewards_profile.rewards_number = "1..11"
    rewards_profile.rewards_number_confirmation = "1..11"
    assert !rewards_profile.save, "sale saved without a numeric rewards number"
    rewards_profile.rewards_number = 11111111
    rewards_profile.rewards_number_confirmation = 11111111
    assert rewards_profile.save, "fixing the rewards number did NOT save the rewards profile" 
  end

  test "can't have rewards profile with a non integer rewards number 2" do
    rewards_profile = RewardsProfile.new
    rewards_profile.profile_id = profiles(:consignor_1).id
    rewards_profile.primary_card = true
    rewards_profile.rewards_number = "1.11"
    rewards_profile.rewards_number_confirmation = "1.11"
    assert !rewards_profile.save, "sale saved without a numeric rewards number"
    rewards_profile.rewards_number = 11111111
    rewards_profile.rewards_number_confirmation = 11111111
    assert rewards_profile.save, "fixing the rewards number did NOT save the rewards profile" 
  end

  test "adding new rewards card to user should make old primary one to be none primary" do
    rewards_profile = RewardsProfile.new
    rewards_profile.profile_id = profiles(:reward_1).id
    rewards_profile.primary_card = true
    rewards_profile.rewards_number = 11111111
    rewards_profile.rewards_number_confirmation = 11111111
    rewards_profile.save
    old_primary_profile = RewardsProfile.find(rewards_profiles(:rewards_profile_1).id)
    assert !old_primary_profile.primary_card, "the existing rewards profile is still the primary card"
  end

  test "adding a valid rewards profile card saves properly" do
    rewards_profile = RewardsProfile.new
    rewards_profile.profile_id = profiles(:consignor_1).id
    rewards_profile.rewards_number = 11111111
    rewards_profile.rewards_number_confirmation = 11111111
    rewards_profile.primary_card = true
    assert rewards_profile.save, " a valid rewards profile did not save" 
  end

  test "making none primary rewards card primary makes the existing primary not primary" do
    new_primary_profile = RewardsProfile.find(rewards_profiles(:rewards_profile_3).id)
    new_primary_profile.primary_card = true
    new_primary_profile.save
    old_primary_profile = RewardsProfile.find(rewards_profiles(:rewards_profile_1).id)
    assert !old_primary_profile.primary_card, "the existing rewards profile is still the primary card"
  end

  test "rewards for purchase of 0 should be 0" do
    assert_equal(RewardsProfile.rewards_for_total_amount(0), 0, "award for 0 dollars was not 0")
  end

  test "rewards for purchase of 50 should be 0" do
    assert_equal(RewardsProfile.rewards_for_total_amount(50), 0, "award for 50 dollars was not 0")
  end

  test "rewards for purchase of 99 should be 0" do
    assert_equal(RewardsProfile.rewards_for_total_amount(99), 0, "award for 99 dollars was not 0")
  end

  test "rewards for purchase of 100 should be 5" do
    assert_equal(RewardsProfile.rewards_for_total_amount(100), 5, "award for 100 dollars was not 5")
  end

  test "rewards for purchase of 150 should be 5" do
    assert_equal(RewardsProfile.rewards_for_total_amount(150), 5, "award for 150 dollars was not 5")
  end

  test "rewards for purchase of 199.99 should be 5" do
    assert_equal(RewardsProfile.rewards_for_total_amount(199.99), 5, "award for 199.99 dollars was not 5")
  end

  test "rewards for purchase of 200 should be 10" do
    assert_equal(RewardsProfile.rewards_for_total_amount(200), 10, "award for 200 dollars was not 10")
  end

  test "rewards for purchase of 300 should be 15" do
    assert_equal(RewardsProfile.rewards_for_total_amount(300), 15, "award for 300 dollars was not 15")
  end

  test "rewards for purchase of 400 should be 20" do
    assert_equal(RewardsProfile.rewards_for_total_amount(400), 20, "award for 400 dollars was not 20")
  end

  test "rewards for purchase of 500 should be 25" do
    assert_equal(RewardsProfile.rewards_for_total_amount(500), 25, "award for 500 dollars was not 25")
  end

  test "rewards for purchase of 1000 should be 50" do
    assert_equal(RewardsProfile.rewards_for_total_amount(1000), 50, "award for 1000 dollars was not 50")
  end

  test "test rewards profile 1 florida sale amount purchased" do
    rewards_profile = RewardsProfile.find(rewards_profiles(:rewards_profile_1).id)
    assert_equal(rewards_profile.amount_purchased(3), 0.0, "amoung purchase for rewards profile 1 florida sale was not 0")
  end
    
  test "test rewards profile 2 florida sale amount purchased" do
    rewards_profile = RewardsProfile.find(rewards_profiles(:rewards_profile_2).id)
    assert_equal(rewards_profile.amount_purchased(3), 90.0, "amoung purchase for rewards profile 2 florida sale was not 90")
  end

  test "test rewards profile 3 florida sale amount purchased" do
    rewards_profile = RewardsProfile.find(rewards_profiles(:rewards_profile_3).id)
    assert_equal(rewards_profile.amount_purchased(3), 250.0, "amoung purchase for rewards profile 3 florida sale was not 100")
  end

  test "test rewards profile 1 kansas sale amount purchased" do
    rewards_profile = RewardsProfile.find(rewards_profiles(:rewards_profile_1).id)
    assert_equal(rewards_profile.amount_purchased(1), 0, "amoung purchase for rewards profile 1 florida sale was not 0")
  end
    
  test "test rewards profile 2 kansas sale amount purchased" do
    rewards_profile = RewardsProfile.find(rewards_profiles(:rewards_profile_2).id)
    assert_equal(rewards_profile.amount_purchased(1), 10.0, "amoung purchase for rewards profile 1 florida sale was not 10")
  end

  test "test rewards profile 3 kansas sale amount purchased" do
    rewards_profile = RewardsProfile.find(rewards_profiles(:rewards_profile_3).id)
    assert_equal(rewards_profile.amount_purchased(1), 100.0, "amoung purchase for rewards profile 1 florida sale was not 100")
  end

  test "rewards_for_franchise for reward profile 1 florida franchise" do
    franchise = Franchise.find(franchises(:florida).id)
    sale = Sale.find(sales(:florida_spring).id)
    sale.calculate_financials
    rewards_profile = RewardsProfile.find(rewards_profiles(:rewards_profile_1).id)
    assert_equal(rewards_profile.single_card_rewards_for_franchise(franchise), 5, "rewards earned for florida franchise rewards profile 1 was not 5")
  end

  test "rewards_for_franchise for reward profile 2 florida franchise" do
    franchise = Franchise.find(franchises(:florida).id)
    sale = Sale.find(sales(:florida_spring).id)
    sale.calculate_financials
    rewards_profile = RewardsProfile.find(rewards_profiles(:rewards_profile_2).id)
    assert_equal(rewards_profile.single_card_rewards_for_franchise(franchise), 0, "rewards earned for florida franchise rewards profile 2 was not 0")
  end

  test "rewards_for_franchise for reward profile 3 florida franchise" do
    franchise = Franchise.find(franchises(:florida).id)
    sale = Sale.find(sales(:florida_spring).id)
    sale.calculate_financials
    rewards_profile = RewardsProfile.find(rewards_profiles(:rewards_profile_3).id)
    assert_equal(rewards_profile.single_card_rewards_for_franchise(franchise), 10, "rewards earned for florida franchise rewards profile 3 was not 10")
  end

  test "rewards_for_franchise for reward profile 1 kansas franchise" do
    franchise = Franchise.find(franchises(:kansas).id)
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    rewards_profile = RewardsProfile.find(rewards_profiles(:rewards_profile_1).id)
    assert_equal(rewards_profile.single_card_rewards_for_franchise(franchise), 0, "rewards earned for kansas franchise rewards profile 1 was not 0")
  end

  test "rewards_for_franchise for reward profile 2 kansas franchise" do
    franchise = Franchise.find(franchises(:kansas).id)
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    rewards_profile = RewardsProfile.find(rewards_profiles(:rewards_profile_2).id)
    assert_equal(rewards_profile.single_card_rewards_for_franchise(franchise), 0, "rewards earned for kansas franchise rewards profile 2 was not 0")
  end

  test "rewards_for_franchise for reward profile 3 kansas franchise" do
    franchise = Franchise.find(franchises(:kansas).id)
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    rewards_profile = RewardsProfile.find(rewards_profiles(:rewards_profile_3).id)
    assert_equal(rewards_profile.single_card_rewards_for_franchise(franchise), 5, "rewards earned for kansas franchise rewards profile 3 was not 5")
  end

  test "add 25 in sales to florida current in reward profile 3 should still be 10 dollar reward" do
    franchise = Franchise.find(franchises(:florida).id)
    sale = Sale.find(sales(:florida_spring).id)
    sale.calculate_financials
    for i in 1..25
      item = ConsignorInventory.find(i + 450)
      item.sale_id = sales(:florida_current).id
      item.sale_price = 1
      item.status = true
      item.tax_collected = 0.08
      item.total_price = 1.08
      item.sale_date = Date.today + 61
      item.transaction_number = 4
      item.discounted_at_sale = false
      item.transaction_import_id = 3
      item.rewards_profile_id = rewards_profiles(:rewards_profile_3).id
      item.save
    end
    sale = Sale.find(sales(:florida_current).id)
    sale.calculate_financials
    rewards_profile = RewardsProfile.find(rewards_profiles(:rewards_profile_3).id)
    assert_equal(rewards_profile.single_card_rewards_for_franchise(franchise), 10, "rewards earned for florida franchise rewards profile 2 was not 10")
  end 

  test "add 125 in sales to florida current in reward profile 3 should add 5 dollar reward" do
    franchise = Franchise.find(franchises(:florida).id)
    sale = Sale.find(sales(:florida_spring).id)
    sale.calculate_financials
    for i in 1..125
      item = ConsignorInventory.find(i + 450)
      item.sale_id = sales(:florida_current).id
      item.sale_price = 1
      item.status = true
      item.tax_collected = 0.08
      item.total_price = 1.08
      item.sale_date = Date.today + 61
      item.transaction_number = 4
      item.discounted_at_sale = false
      item.transaction_import_id = 3
      item.rewards_profile_id = rewards_profiles(:rewards_profile_3).id
      item.save
    end
    sale = Sale.find(sales(:florida_current).id)
    sale.calculate_financials
    rewards_profile = RewardsProfile.find(rewards_profiles(:rewards_profile_3).id)
    assert_equal(rewards_profile.single_card_rewards_for_franchise(franchise), 15, "rewards earned for florida franchise rewards profile 2 was not 15")
  end 
  
  test "add 50 in sales to florida spring in reward profile 4 should recognize reward in franchise rewards profiles" do
    franchise = Franchise.find(franchises(:florida).id)
    for i in 1..50
      item = ConsignorInventory.find(i + 450)
      item.sale_id = sales(:florida_spring).id
      item.sale_price = 1
      item.status = true
      item.tax_collected = 0.08
      item.total_price = 1.08
      item.sale_date = sales(:florida_spring).start_date
      item.transaction_number = 4
      item.discounted_at_sale = false
      item.transaction_import_id = 3
      item.rewards_profile_id = rewards_profiles(:rewards_profile_4).id
      item.save
    end
    sale = Sale.find(sales(:florida_spring).id)
    sale.calculate_financials
    assert_equal(franchise.rewards_profiles, 
      [ 
        RewardsProfile.find(rewards_profiles(:rewards_profile_1).id),
        RewardsProfile.find(rewards_profiles(:rewards_profile_2).id)
      ], "rewards profiles for Florida franchise did not match up")
  end 
  
  test "add 50 in sales to florida spring in reward profile 4 should create 5 dollar reward for rewards profile 2" do
    franchise = Franchise.find(franchises(:florida).id)
    for i in 1..50
      item = ConsignorInventory.find(i + 450)
      item.sale_id = sales(:florida_spring).id
      item.sale_price = 1
      item.status = true
      item.tax_collected = 0.08
      item.total_price = 1.08
      item.sale_date = sales(:florida_spring).start_date
      item.transaction_number = 4
      item.discounted_at_sale = false
      item.transaction_import_id = 3
      item.rewards_profile_id = rewards_profiles(:rewards_profile_4).id
      item.save
    end
    sale = Sale.find(sales(:florida_spring).id)
    sale.calculate_financials
    rewards_profile = RewardsProfile.find(rewards_profiles(:rewards_profile_2).id)
    assert_equal(rewards_profile.rewards_for_franchise(franchise), 5, "rewards earned for florida franchise rewards profile 2 was not 5")
  end
  
  test "purchases by user with two rewards cards should add up right in florida sale rewards profile 1" do
    sale = Sale.find(sales(:florida_spring).id)
    sale.calculate_financials
    rewards_profile = RewardsProfile.find(rewards_profiles(:rewards_profile_1).id)
    assert_equal(rewards_profile.amount_purchased_in_sale(sale), 250.0, "amount purchase reward profile 1 in florida sale was not 250")
  end
  
  test "purchases by user with two rewards cards should add up right in florida sale rewards profile 3" do
    sale = Sale.find(sales(:florida_spring).id)
    sale.calculate_financials
    rewards_profile = RewardsProfile.find(rewards_profiles(:rewards_profile_3).id)
    assert_equal(rewards_profile.amount_purchased_in_sale(sale), 250.0, "amount purchase reward profile 3 in florida sale was not 250")
  end
  
  test "purchases by user with two rewards cards should add up right in kansas sale rewards profile 1" do
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    rewards_profile = RewardsProfile.find(rewards_profiles(:rewards_profile_1).id)
    assert_equal(rewards_profile.amount_purchased_in_sale(sale), 100.0, "amount purchase reward profile 1 in florida sale was not 250")
  end
  
  test "purchases by user with two rewards cards should add up right in kansas sale rewards profile 3" do
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    rewards_profile = RewardsProfile.find(rewards_profiles(:rewards_profile_3).id)
    assert_equal(rewards_profile.amount_purchased_in_sale(sale), 100.0, "amount purchase reward profile 3 in florida sale was not 250")
  end
  
  test "rewards for franchise for florida franchise rewards profile 3" do
    franchise = Franchise.find(franchises(:florida).id)
    rewards_profile = RewardsProfile.find(rewards_profiles(:rewards_profile_3).id)
    for sale in franchise.sales
      sale.calculate_financials
    end
    assert_equal(rewards_profile.rewards_for_franchise(franchise), 15, "rewards for franchise was not 15")
  end

  test "rewards for franchise for kansas franchise rewards profile 1" do
    franchise = Franchise.find(franchises(:kansas).id)
    rewards_profile = RewardsProfile.find(rewards_profiles(:rewards_profile_1).id)
    for sale in franchise.sales
      sale.calculate_financials
    end
    assert_equal(rewards_profile.rewards_for_franchise(franchise), 5, "rewards for franchise was not 5")
  end
  
  test "rewards for franchise for florida franchise rewards profile 1" do
    franchise = Franchise.find(franchises(:florida).id)
    rewards_profile = RewardsProfile.find(rewards_profiles(:rewards_profile_1).id)
    for sale in franchise.sales
      sale.calculate_financials
    end
    assert_equal(rewards_profile.rewards_for_franchise(franchise), 15, "rewards for franchise was not 15")
  end

  test "add 125 in purcases for for florida current sale should make franchise rewards profile 1 total be 15" do
    for i in 1..125
      item = ConsignorInventory.find(i + 450)
      item.sale_id = sales(:florida_current).id
      item.sale_price = 1
      item.status = true
      item.tax_collected = 0.08
      item.total_price = 1.08
      item.sale_date = Date.today + 61
      item.transaction_number = 4
      item.discounted_at_sale = false
      item.transaction_import_id = 3
      item.rewards_profile_id = rewards_profiles(:rewards_profile_1).id
      item.save
    end
    franchise = Franchise.find(franchises(:florida).id)
    rewards_profile = RewardsProfile.find(rewards_profiles(:rewards_profile_1).id)
    for sale in franchise.sales
      sale.calculate_financials
    end
    assert_equal(rewards_profile.rewards_for_franchise(franchise), 20, "rewards for franchise was not 20")
  end

  test "add 75 in purcases for for florida current sale should make franchise rewards profile 1 total still be 10" do
    for i in 1..75
      item = ConsignorInventory.find(i + 450)
      item.sale_id = sales(:florida_current).id
      item.sale_price = 1
      item.status = true
      item.tax_collected = 0.08
      item.total_price = 1.08
      item.sale_date = Date.today + 61
      item.transaction_number = 4
      item.discounted_at_sale = false
      item.transaction_import_id = 3
      item.rewards_profile_id = rewards_profiles(:rewards_profile_1).id
      item.save
    end
    franchise = Franchise.find(franchises(:florida).id)
    rewards_profile = RewardsProfile.find(rewards_profiles(:rewards_profile_1).id)
    for sale in franchise.sales
      sale.calculate_financials
    end
    assert_equal(rewards_profile.rewards_for_franchise(franchise), 15, "rewards for franchise was not 15")
  end

  test "rewards_profile_for_franchise returns correct records" do
    item = ConsignorInventory.find(451)
    item.sale_id = sales(:florida_current).id
    item.sale_price = 1
    item.status = true
    item.tax_collected = 0.08
    item.total_price = 1.08
    item.sale_date = Date.today + 61
    item.transaction_number = 4
    item.discounted_at_sale = false
    item.transaction_import_id = 3
    item.rewards_profile_id = rewards_profiles(:rewards_profile_5).id
    item.save
    franchise = Franchise.find(franchises(:florida).id)
    for sale in franchise.sales
      sale.calculate_financials
    end
    assert_equal(franchise.rewards_profiles, 
      [ 
        RewardsProfile.find(rewards_profiles(:rewards_profile_1).id)
      ], "rewards profiles for Florida franchise did not match up")
  end

  test "profile returns correct primary card" do
    profile = Profile.find(profiles(:reward_1).id)
    assert_equal(profile.primary_rewards_profile, RewardsProfile.find(rewards_profiles(:rewards_profile_1).id), "profile for rewards card 1 did not find correct primary card")
  end

  test "sales for profile rewards_1" do 
    sales = Sale.find(:all)
    for sale in sales
      sale.calculate_financials
    end
    profile = Profile.find(profiles(:reward_1).id)
    assert_equal(RewardsProfile.sales_for_profile(profile), [Sale.find(sales(:kansas_spring).id), Sale.find(sales(:florida_spring).id)], "sales for reward_1 profile did not load right")    
  end

  test "franchises for profile rewards_1" do 
    sales = Sale.find(:all)
    for sale in sales
      sale.calculate_financials
    end
    profile = Profile.find(profiles(:reward_1).id)
    assert_equal(RewardsProfile.franchises_for_profile(profile), [Franchise.find(franchises(:florida).id), Franchise.find(franchises(:kansas).id)], "franchises for reward_1 profile did not load right")    
  end

  test "current primary card for reward_1 should be reward_profile_1" do
    assert_equal(RewardsProfile.current_primary_card(profiles(:reward_1).id), RewardsProfile.find(rewards_profiles(:rewards_profile_1).id), "current primary card does not match for rewards_1 profile")
  end

  test "load reward dropdown test for 20 dollars max" do
    assert_equal(RewardsProfile.reward_amount_drop_down_options(20), [[20, 20], [15, 15], [10, 10], [5, 5]], "problem loading the rewards dropdown")
  end

  test "rewards profile 1 has rewards in florida franchise" do
    franchise = Franchise.find(franchises(:florida).id)
    rewards_profile = RewardsProfile.find(rewards_profiles(:rewards_profile_1).id)
    for sale in franchise.sales
      sale.calculate_financials
    end
    assert rewards_profile.has_rewards_in_franchise(franchise), "rewards profile 1 does not show reward for florida franchise"
  end

  test "rewards profile 2 has rewards in florida franchise" do
    franchise = Franchise.find(franchises(:florida).id)
    rewards_profile = RewardsProfile.find(rewards_profiles(:rewards_profile_2).id)
    for sale in franchise.sales
      sale.calculate_financials
    end
    assert !rewards_profile.has_rewards_in_franchise(franchise), "rewards profile 2 does not show reward for florida franchise"
  end

  test "rewards profile 3 has rewards in florida franchise" do
    franchise = Franchise.find(franchises(:florida).id)
    rewards_profile = RewardsProfile.find(rewards_profiles(:rewards_profile_3).id)
    for sale in franchise.sales
      sale.calculate_financials
    end
    assert rewards_profile.has_rewards_in_franchise(franchise), "rewards profile 3 does not show reward for florida franchise"
  end

  test "rewards profile 4 has rewards in florida franchise" do
    franchise = Franchise.find(franchises(:florida).id)
    rewards_profile = RewardsProfile.find(rewards_profiles(:rewards_profile_4).id)
    for sale in franchise.sales
      sale.calculate_financials
    end
    assert !rewards_profile.has_rewards_in_franchise(franchise), "rewards profile 4 does not show reward for florida franchise"
  end

  test "rewards profile 5 has rewards in florida franchise" do
    franchise = Franchise.find(franchises(:florida).id)
    rewards_profile = RewardsProfile.find(rewards_profiles(:rewards_profile_5).id)
    for sale in franchise.sales
      sale.calculate_financials
    end
    assert !rewards_profile.has_rewards_in_franchise(franchise), "rewards profile 5 shows reward for florida franchise"
  end
end
