# frozen_string_literal: true

class AuthConfig

  AUTH_CONFIG_PATH = Rails.root.join('config/auth.yml')

  class << self
    def auth_config
      @@auth_config ||= new
    end

    def ldap_settings
      auth_config.ldap.dup
    end

    def oicd_enabled?
      auth_config.oicd?
    end

    def ldap_enabled?
      auth_config.ldap?
    end

    def db_enabled?
      auth_config.db?
    end

    def provider
      auth_config.provider
    end
  end

  def provider
    settings_file[:provider]
  end

  def oicd?
    provider == 'openid-connect'
  end

  def oicd
    settings_file[:oicd]
  end

  def ldap?
    provider == 'ldap'
  end

  def db?
    provider == 'db'
  end

  def ldap
    settings_file[:ldap]
  end

  private

  def settings_file
    @settings_file ||= load_file.freeze
  end

  def load_file
    return { provider: 'db' } unless valid_file?

    YAML.safe_load(File.read(AUTH_CONFIG_PATH)).deep_symbolize_keys
  end

  def valid_file?
    File.exist?(AUTH_CONFIG_PATH) && !File.zero?(AUTH_CONFIG_PATH)
  end
end
