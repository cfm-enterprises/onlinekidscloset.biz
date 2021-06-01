require File.dirname(__FILE__) + '/../test_helper'

class FranchiseProfileTest < ActiveSupport::TestCase
  # Replace this with your real tests.

  fixtures :franchise_profiles
    
  test "check fixtures loaded one franchise profile" do
    assert_equal 15, FranchiseProfile.count
  end
end
