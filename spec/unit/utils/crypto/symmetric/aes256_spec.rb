# frozen_string_literal: true

require 'spec_helper'

require_relative '../../../../../app/utils/crypto/symmetric/aes256'
require_relative '../../../../../app/utils/crypto/rsa'

describe Crypto::Symmetric::Aes256 do

  let(:keypair) { Crypto::Rsa.generate_new_keypair }
  let(:private_key) { keypair.to_s }
  let(:public_key) { keypair.public_key.to_s }
  let(:team_password) { Crypto::Symmetric::Aes256.random_key }

  it 'encrypts and decrypts private key' do
    encrypted_private_key = Crypto::Symmetric::Aes256.encrypt_with_salt(private_key, team_password)
    decrypted_private_key = Crypto::Symmetric::Aes256.decrypt_with_salt(
      encrypted_private_key,
      team_password
    )
    expect(private_key).to eq(decrypted_private_key)
  end

  it 'encrypts and decrypts data' do
    cleartext_data = Base64.decode64('test')
    cleartext_data_encrypted = Crypto::Symmetric::Aes256.encrypt(cleartext_data, team_password)
    result = Crypto::Symmetric::Aes256.decrypt(cleartext_data_encrypted, team_password)
    expect(cleartext_data).to eq(result)
  end
end
