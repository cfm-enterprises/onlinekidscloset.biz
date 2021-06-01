require File.dirname(__FILE__) + '/../test_helper'

class FranchiseRewardsAdjustmentTest < ActiveSupport::TestCase
  # Replace this with your real tests.

  fixtures :rewards_profiles, :franchise_rewards_adjustments

  test "check fixtures got loaded" do
    assert_equal 1, FranchiseRewardsAdjustment.count
  end
  
  test "rewards adjustment must belong to a franchise" do
  	adjustment = FranchiseRewardsAdjustment.new
  	adjustment.rewards_number = "10000001"
  	adjustment.amount = 5
    assert !adjustment.save, "Saved Reward Adjustment without Franchise"
    adjustment.franchise_id = 1
    assert adjustment.save, "Adding the Franchise did not save the Reward Adjustment"
  end

  test "rewards adjustment must belong to a rewards profile" do
  	adjustment = FranchiseRewardsAdjustment.new
    adjustment.franchise_id = 1
  	adjustment.amount = 5
    assert !adjustment.save, "Saved Reward Adjustment without Rewards Profile"
  	adjustment.rewards_number = "10000001"
    assert adjustment.save, "Adding the Rewards Profile did not save the Reward Adjustment"
  end

  test "rewards adjustment must confirm the rewards number" do
    adjustment = FranchiseRewardsAdjustment.new
    adjustment.rewards_number = "11000001"
    adjustment.franchise_id = 1
    adjustment.amount = 5
    assert !adjustment.save, "Saved Reward Adjustment without Rewards Number Confirmation"
    adjustment.rewards_number_confirmation = "11000001"
    assert adjustment.save, "Adding the Rewards Number Confirmation did not save the Reward Adjustment"
  end

  test "rewards adjustment must have an amount" do
  	adjustment = FranchiseRewardsAdjustment.new
    adjustment.franchise_id = 1
  	adjustment.rewards_number = "10000001"
    assert !adjustment.save, "Saved Reward Adjustment without Amount"
  	adjustment.amount = 5
    assert adjustment.save, "Adding the Amount did not save the Reward Adjustment"
  end

  test "rewards adjustment must have an amount of at least 5" do
  	adjustment = FranchiseRewardsAdjustment.new
    adjustment.franchise_id = 1
  	adjustment.rewards_number = "10000001"
  	adjustment.amount = 0
    assert !adjustment.save, "Saved Reward Adjustment with Invalid Amount"
  	adjustment.amount = 5
    assert adjustment.save, "Fixing the Amount did not save the Reward Adjustment"
  end

  test "rewards adjustment must have an amount of less than 100" do
  	adjustment = FranchiseRewardsAdjustment.new
    adjustment.franchise_id = 1
  	adjustment.rewards_number = "10000001"
  	adjustment.amount = 105
    assert !adjustment.save, "Saved Reward Adjustment with Invalid Amount"
  	adjustment.amount = 5
    assert adjustment.save, "Fixing the Amount did not save the Reward Adjustment"
  end

  test "rewards adjustment must have an amount of a multiple of 5" do
  	adjustment = FranchiseRewardsAdjustment.new
    adjustment.franchise_id = 1
  	adjustment.rewards_number = "10000001"
  	adjustment.amount = 44
    assert !adjustment.save, "Saved Reward Adjustment with Invalid Amount"
  	adjustment.amount = 5
    assert adjustment.save, "Fixing the Amount did not save the Reward Adjustment"
  end

  test "rewards adjustment with new rewards number saves properly" do
  	adjustment = FranchiseRewardsAdjustment.new
    adjustment.franchise_id = 1
  	adjustment.rewards_number = "11000001"
    adjustment.rewards_number_confirmation = "11000001"
  	adjustment.amount = 5
    assert adjustment.save, "Rewards Adjustment did not saved"
  end

  test "rewards adjustment with new rewards number adds one to the Rewarsd Profile count" do
  	old_count = RewardsProfile.count
  	adjustment = FranchiseRewardsAdjustment.new
    adjustment.franchise_id = 1
  	adjustment.rewards_number = "11000001"
    adjustment.rewards_number_confirmation = "11000001"
  	adjustment.amount = 5
    assert adjustment.save
    assert_equal RewardsProfile.count, old_count + 1, "The Rewards Profile count did not adjust properly"
  end
end
