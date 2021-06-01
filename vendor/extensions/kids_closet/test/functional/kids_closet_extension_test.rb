require File.dirname(__FILE__) + '/../test_helper'

class KidsClosetExtensionTest < Test::Unit::TestCase
  
  # Replace this with your real tests.
  def test_this_extension
    assert true
  end
  
  def test_initialization
    assert_equal File.join(File.expand_path(RAILS_ROOT), 'vendor', 'extensions', 'kids_closet'), KidsClosetExtension.root
    assert_equal 'Kids Closet', KidsClosetExtension.extension_name
  end
  
end
