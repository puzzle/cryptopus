# frozen_string_literal: true

class AuthConfig

  PATH = Rails.root.join('config/auth.yml')

  class << self
    def auth_config
      @@auth_config ||= new
    end

    def ldap_settings
      @@ldap_settings ||= auth_config.ldap
    end

    def ldap_enabled?
      @@ldap_enabled ||= auth_config.ldap_enabled?
    end

    def provider
      @@provider ||= auth_config.provider
    end
  end

  def provider
    settings_file[:provider]
  end

  def ldap_enabled?
    provider == 'ldap'
  end

  def ldap
    settings_file[:ldap]
  end

  private

  def settings_file
    @settings_file ||= load_file
  end

  def load_file
    return { provider: 'db' } unless valid_file?

    YAML.safe_load(File.read(PATH)).deep_symbolize_keys
  end

  def valid_file?
    File.exist?(PATH) && !File.zero?(PATH)
  end
end
