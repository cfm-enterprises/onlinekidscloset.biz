require File.dirname(__FILE__) + '/../test_helper'

class SaleVolunteerSignUpTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "check fixtures got loaded" do
    assert_equal 12, SaleVolunteerSignUp.count
  end

  test "can't sign up for same volunteer slot" do
  	volunteer_sign_up = SaleVolunteerSignUp.new
  	volunteer_sign_up.sale_volunteer_time_id = 1
  	volunteer_sign_up.franchise_profile_id = 9
  	assert !volunteer_sign_up.save
  end

  test "can't sign up for more than 6 slots" do 
  	volunteer_sign_up = SaleVolunteerSignUp.new
  	volunteer_sign_up.sale_volunteer_time_id = 7
  	volunteer_sign_up.franchise_profile_id = 9
  	assert !volunteer_sign_up.save
  end

  test "valid sign up works" do
  	volunteer_sign_up = SaleVolunteerSignUp.new
  	volunteer_sign_up.sale_volunteer_time_id = 7
  	volunteer_sign_up.franchise_profile_id = 11
  	assert volunteer_sign_up.save
  end

end
