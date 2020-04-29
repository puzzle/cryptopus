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

def enable_keycloak
  expect(AuthConfig).to receive(:keycloak_enabled?).and_return(true).at_least(:once)
end

def enable_ldap
  expect(AuthConfig).to receive(:ldap_enabled?).and_return(true).at_least(:once)
end

def stub_geo_ip
  allow(GeoIp).to receive(:activated?).at_least(:once).and_return(nil)
end

def mock_ldap_settings
  allow(AuthConfig).to receive(:ldap_settings).and_return(ldap_settings).at_least(:once)
end

def ldap_settings
  {
    bind_dn: 'example_bind_dn',
    bind_password: 'ZXhhbXBsZV9iaW5kX3Bhc3N3b3Jk',
    encryption: 'simple_tls',
    hostnames: ['example_hostname'],
    basename: 'ou=users,dc=acme',
    portnumber: 636
  }
end
