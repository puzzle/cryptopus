# frozen_string_literal: true

require 'spec_helper'

require_relative '../../../../../app/utils/crypto/symmetric/AES256IV'

describe Crypto::Symmetric::AES256IV do
  let(:keypair) { Crypto::RSA.generate_new_keypair }
  let(:private_key) { keypair.to_s }
  let(:public_key) { keypair.public_key.to_s }
  let(:team_password) { described_class.random_key }

  it 'should encrypt and decrypt data' do
    key = team_password
    data = Base64.strict_decode64('test')
    encrypted_values = described_class.encrypt(data, key)
    data_encrypted = encrypted_values.first
    iv = encrypted_values.second

    result = described_class.decrypt(data_encrypted, key, iv)
    encoded_result = Base64.strict_encode64(result)
    expect(encoded_result).to eq('test')
  end
end