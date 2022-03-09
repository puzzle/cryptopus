# frozen_string_literal: true

def decrypt_private_key(user)
  user.decrypt_private_key('password')
end

def legacy_encrypt_private_key(private_key, password)
  cipher = OpenSSL::Cipher.new('aes-256-cbc')
  cipher.encrypt
  cipher.key = password.unpack('a2' * 32).map { |x| x.hex }.pack('c' * 32)
  encrypted_private_key = cipher.update(private_key)
  encrypted_private_key << cipher.final
  encrypted_private_key
end

def enable_openid_connect
  allow_any_instance_of(AuthConfig)
    .to receive(:settings_file)
    .and_return(oidc_settings)
  Rails.application.reload_routes!
end

def enable_ldap
  allow_any_instance_of(AuthConfig)
    .to receive(:settings_file)
    .and_return(ldap_settings)
  Rails.application.reload_routes!
end

def enable_db_auth
  allow(AuthConfig.auth_config).to receive(:provider).and_return('db')
  Rails.application.reload_routes!
end

def stub_geo_ip
  allow(GeoIp).to receive(:activated?).at_least(:once).and_return(nil)
end

def ldap_settings
  {
    provider: 'ldap',
    ldap: {
      bind_dn: 'example_bind_dn',
      bind_password: 'ZXhhbXBsZV9iaW5kX3Bhc3N3b3Jk',
      encryption: 'simple_tls',
      hostnames: ['ldap1.example.com'],
      basename: 'ou=users,dc=acme',
      portnumber: 636
    }
  }
end

def oidc_settings
  YAML.safe_load(
    File.read('spec/fixtures/files/auth/auth.yml.oidc.test')
  ).deep_symbolize_keys
end

# static team passwords extracted from fixtures
def team1_password
  Base64.strict_decode64('LPTDTUOnL201Fn24GYP8ZRpE79m9ucBY8cF/tcCKcCs=')
end

def team2_password
  Base64.strict_decode64('Xyj5d0yF9D/XOCIi9Iz5bsgNs9KvvcKkJAtCsoENNj4=')
end
