# frozen_string_literal: true

require 'spec_helper'

require_relative '../../../../app/utils/crypto/rsa'
require_relative '../../../../app/utils/crypto/symmetric'

describe Crypto::Rsa do
  let(:keypair) { Crypto::Rsa.generate_new_keypair }
  let(:private_key) { keypair.to_s }
  let(:public_key) { keypair.public_key.to_s }
  let(:team_password) { ::Crypto::Symmetric::Aes256.random_key }

  it 'encrypts and decrypts data' do
    encrypted_password = Crypto::Rsa.encrypt(team_password, public_key)
    decrypted_password = Crypto::Rsa.decrypt(encrypted_password, private_key)
    expect(team_password).to eq(decrypted_password)
  end

  it 'does not raise exception if valid keypair' do
    Crypto::Rsa.validate_keypair(private_key, public_key)
  end

  it 'raises execption if keypair does not match' do
    public_key = Crypto::Rsa.generate_new_keypair.public_key.to_s
    expect do
      Crypto::Rsa.validate_keypair(private_key, public_key)
    end.to raise_error(Exceptions::DecryptFailed)
  end
end
