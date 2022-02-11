# frozen_string_literal: true

require 'spec_helper'

describe Crypto::RSA do
  let(:keypair) { RSA.generate_new_keypair }
  let(:private_key) { keypair.to_s }
  let(:public_key) { keypair.public_key.to_s }
  let(:team_password) { Symmetric::AES256.random_key }

  it 'encrypts and decrypts data' do
    encrypted_password = RSA.encrypt(team_password, public_key)
    decrypted_password = RSA.decrypt(encrypted_password, private_key)
    expect(team_password).to eq(decrypted_password)
  end

  it 'should not raise exception if valid keypair' do
    RSA.validate_keypair(private_key, public_key)
  end

  it 'should raise expection if keypair does not match' do
    public_key = RSA.generate_new_keypair.public_key.to_s
    expect do
      RSA.validate_keypair(private_key, public_key)
    end.to raise_error(Exceptions::DecryptFailed)
  end
end