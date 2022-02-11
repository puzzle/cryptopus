# frozen_string_literal: true

require 'spec_helper'

require_relative '../../../../../app/utils/crypto/symmetric/AES256'
require_relative '../../../../../app/utils/crypto/RSA'

describe Crypto::Symmetric::AES256 do

  let(:keypair) { Crypto::RSA.generate_new_keypair }
  let(:private_key) { keypair.to_s }
  let(:public_key) { keypair.public_key.to_s }
  let(:team_password) { Crypto::Symmetric::AES256.random_key }

  it 'should encrypt and decrypt private key' do
    require 'pry'; binding.pry unless $pstop
    encrypted_private_key = Crypto::Symmetric::AES256.encrypt_with_salt(private_key, team_password)
    decrypted_private_key = Crypto::Symmetric::AES256.decrypt_with_salt(encrypted_private_key, team_password)
    expect(private_key).to eq(decrypted_private_key)
  end

  it 'should encrypt and decrypt blob data' do
    blob_data = Base64.decode64('test')
    blob_data_encrypted = Crypto::Symmetric::AES256.encrypt(blob_data, team_password)
    result = Crypto::Symmetric::AES256.decrypt(blob_data_encrypted, team_password)
    expect(blob_data.force_encoding('UTF-8')).to eq(result)
  end
end