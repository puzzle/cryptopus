ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/autorun"
require 'mocha/test_unit'
Dir[Rails.root.join('test/support/**/*.rb')].sort.each { |f| require f }

class ActiveSupport::TestCase
  setup :stub_ldap_tools
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  #Disable LDAP connection
  def stub_ldap_tools
    LdapTools.stubs(:ldap_login)
  end
  # Add more helper methods to be used by all tests here...

end
