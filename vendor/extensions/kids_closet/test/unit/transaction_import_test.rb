require File.dirname(__FILE__) + '/../test_helper'

class TransactionImportTest < ActiveSupport::TestCase
  test "check fixtures loaded two imports" do
    assert_equal 2, TransactionImport.count
  end

end
