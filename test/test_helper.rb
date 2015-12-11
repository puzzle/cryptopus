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

  def legacy_encrypt_private_key(private_key, password)
    cipher = OpenSSL::Cipher::Cipher.new( "aes-256-cbc" )
    cipher.encrypt
    cipher.key = password.unpack( 'a2'*32 ).map{|x| x.hex}.pack( 'c'*32 )
    encrypted_private_key = cipher.update( private_key )
    encrypted_private_key << cipher.final()
    encrypted_private_key
  end

end
