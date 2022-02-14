# frozen_string_literal: true

require 'spec_helper'

require_relative '../../../../../app/utils/crypto/symmetric/aes256iv'

describe Crypto::Symmetric::AES256IV do
  let(:keypair) { Crypto::RSA.generate_new_keypair }
  let(:private_key) { keypair.to_s }
  let(:public_key) { keypair.public_key.to_s }
  let(:team_password) { described_class.random_key }

  it 'encrypts and decrypts data with iv' do
    key = team_password
    data = Base64.strict_decode64('test')
    encrypted_values = described_class.encrypt(data, key)
    encrypted_data, iv = encrypted_values

    result = described_class.decrypt(encrypted_data, key, iv)
    encoded_result = Base64.strict_encode64(result)
    expect(encoded_result).to eq('test')
  end
end
