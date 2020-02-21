# frozen_string_literal: true

class AuthConfig

  def initialize(path = 'config/auth.yml')
    @path = path
  end

  class << self
    def ldap_settings
      @@ldap_settings ||= new.ldap
    end

    def ldap_enabled?
      @@ldap_enabled ||= new.ldap_enabled?
    end

    def provider
      @@provider ||= new.provider
    end
  end

  def provider
    settings_file[:provider]
  end

  def ldap_enabled?
    return false unless File.exist?(Rails.root.join(@path)) || provider != 'ldap'

    LdapConnection::MANDATORY_LDAP_SETTING_KEYS.any? { |k| settings_file[:ldap][k] }
  rescue StandardError
    false
  end

  def ldap
    validate_ldap(settings_file[:ldap])
  end

  private

  def validate_ldap(settings)
    raise ArgumentError, 'No ldap settings' if settings.blank?

    encryptions = { 'simple_tls' => :simple_tls, 'start_tls' => :start_tls }
    LdapConnection::MANDATORY_LDAP_SETTING_KEYS.each do |k|
      raise ArgumentError, "missing config field: #{k}" if settings[k].blank?
    end
    settings[:encryption] = encryptions[settings[:encryption]] || :simple_tls
    password = settings[:bind_password]
    settings[:bind_password] = Base64.decode64(password) if password.present?
    settings
  end

  def settings_file
    @settings_file ||= load_file
  end

  def load_file
    return { provider: 'db' } unless valid_file?

    YAML.safe_load(File.read(Rails.root.join(@path))).deep_symbolize_keys
  end

  def valid_file?
    File.exist?(Rails.root.join(@path)) && File.zero?(Rails.root.join(@path)) == false
  end
end
