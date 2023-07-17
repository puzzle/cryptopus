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

def prepare_transferred_encryptable(bob, alice, encryption_algorithm)
  encryptable_file = Encryptable::File.new(name: 'file',
                                           folder_id: bob.inbox_folder.id,
                                           cleartext_file: file_fixture('test_file.txt').read,
                                           content_type: 'text/plain')

  transfer_password = encryption_algorithm.random_key

  encryptable_file.encrypt(transfer_password)

  encrypted_transfer_password = Crypto::Rsa.encrypt(
    transfer_password,
    bob.public_key
  )
  encryptable_file.encrypted_transfer_password = Base64.encode64(encrypted_transfer_password)
  encryptable_file.sender_id = alice.id
  encryptable_file.folder = bob.inbox_folder
  encryptable_file.save!

  encryptable_file
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
  Base64.strict_decode64('lxJqm1TGdue4y9b/njzh+vKtDXESeywOpu+kPp7qTJ8=')
end

def team2_password
  Base64.strict_decode64('A/UIOlRXNYTZDWsRBZmHwuTiujU/2HRi5rIQ8QNvWMA=')
end
