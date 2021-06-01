require File.dirname(__FILE__) + '/../test_helper'

class ProfileTest < ActiveSupport::TestCase
  fixtures :profiles
  
  test "check fixtures got loaded" do
    assert_equal 58, Profile.count
  end

  test "items coming counts correctly" do
    profile = profiles(:consignor_1)
    assert_equal profile.items_coming, 100
  end

  test "new profile must have a phone" do
  	profile = Profile.new
  	profile.email = "test@newprofile.com"
  	profile.email_confirmation = "test@newprofile.com"
  	profile.first_name = "Test"
  	profile.last_name = "User"
  	assert !profile.save
  	profile.phone = "1"
  	assert profile.save
  end

  test "new profile saved a sort letter" do
    profile = Profile.new
    profile.email = "test@newprofile.com"
    profile.email_confirmation = "test@newprofile.com"
    profile.first_name = "Test"
    profile.last_name = "User"
    profile.phone = "1"
    profile.save  
    assert !profile.sort_column.nil?
  end 
end