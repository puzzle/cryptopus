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
    LdapTools.stubs(:get_uid_by_username).returns(42)
    LdapTools.stubs(:connect)
    LdapTools.stubs(:get_ldap_info)
  end

  #@TODO ------RMOVE AFTER RAILS v4 UPGRADE------
  def assert_not(object, message = nil)
        message ||= "Expected #{mu_pp(object)} to be nil or false"
        assert !object, message
      end
  # Add more helper methods to be used by all tests here...

end
