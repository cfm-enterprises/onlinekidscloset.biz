require 'test/unit'
# Load the environment
unless defined? BIONIC_ROOT
  ENV["RAILS_ENV"] = "test"
  require "#{File.expand_path(File.dirname(__FILE__) + "/../../../../")}/config/environment"
end
require "#{RAILS_ROOT}/vendor/bionic/test/test_helper"

class ActiveSupport::TestCase
  
  # Include a helper to make testing Radius tags easier
  #test_helper :extension_tags
  
  # Add the fixture directory to the fixture path
  self.fixture_path = File.dirname(__FILE__) + "/fixtures"
  fixtures :all
  
  # Add more helper methods to be used by all extension tests here...
  Site.current_site_id = 1
end