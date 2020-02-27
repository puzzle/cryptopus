
namespace :ldap do
  desc 'test connection to ldap server'
  task :test do
    ldap_connection_test = LdapConnectionTest.new
    ldap_connection_test.new
  end
end

require_relative '../ldap_connection'
require 'auth_config'

class LdapConnectionTest
  def new
    unless AuthConfig.ldap_enabled?
      puts 'Ldap is diasabled'
      return
    end
    print_settings
    begin
      test_ldap
    rescue ArgumentError
      hostlist_error
    end
    print_messages
  end

  private

  def print_settings
    AuthConfig.ldap_settings.each do |setting, value|
      if setting == :bind_password
        puts "#{setting.to_s}: #{value[0,3]}******"
      else
        puts "#{setting.to_s}: #{value}"
      end
    end
  end

  def print_messages
    puts "info: #{messages[:info].to_s}"
    puts "errors: #{messages[:errors]}"
  end

  def test_ldap
    ldap = LdapConnection.new
    hosts = ldap.test
    hosts_status_messages(hosts)
  end

  def hosts_status_messages(hosts)
    hosts[:success].each do |host|
      hostname_info(host)
    end

    hosts[:failed].each do |host|
      hostname_error(host)
    end
  end

  def hostlist_error
    add_error('No hostname present')
  end

  def hostname_info(hostname)
    add_info("Connection to Ldap Server #{hostname} successful")
  end

  def hostname_error(hostname)
    add_error("Connection to Ldap Server #{hostname} failed")
  end

  def add_error(msg)
    messages[:errors] << msg
  end

  def add_info(msg)
    messages[:info] << msg
  end

  def messages
    @messages ||=
      { errors: [], info: [] }
  end
end
