# frozen_string_literal: true

require 'spec_helper'

describe Asymmetric do
  let(:keypair) { Asymmetric.generate_new_keypair }
  let(:private_key) { keypair.to_s }
  let(:public_key) { keypair.public_key.to_s }
  let(:team_password) { Symmetric::AES256.random_key }

  it 'should encrypt and decrypt team password' do
    encrypted_password = Asymmetric.encrypt(team_password, public_key)
    decrypted_password = Asymmetric.decrypt(encrypted_password, private_key)
    expect(team_password).to eq(decrypted_password)
  end

  it 'should not raise exception if valid keypair' do
    Asymmetric.validate_keypair(private_key, public_key)
  end

  it 'should raise expection if keypair does not match' do
    public_key = Asymmetric.generate_new_keypair.public_key.to_s
    expect do
      Asymmetric.validate_keypair(private_key, public_key)
    end.to raise_error(Exceptions::DecryptFailed)
  end
end