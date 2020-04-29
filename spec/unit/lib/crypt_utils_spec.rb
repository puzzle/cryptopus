# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'


describe CryptUtils do

  before do
    @password = 'foo password'
    @team_password = CryptUtils.new_team_password
    keypair = CryptUtils.new_keypair
    @private_key = CryptUtils.extract_private_key(keypair)
    @public_key = CryptUtils.extract_public_key(keypair)
  end

  context '#legacy_one_way_crypt' do
    it 'should create SHA1 password hash' do
      sha1hash = 'f79b1011916180fead65ac4e199dd607e89fa411'
      expect(CryptUtils.legacy_one_way_crypt(@password)).to eq(sha1hash)
    end
  end

  context '#one_way_crypt' do
    it 'should create SHA512 password hash' do
      hash = CryptUtils.one_way_crypt(@password)
      expect(hash).to match(/^sha512\$.*\$.*/)
    end
  end

  context 'team password' do
    it 'should enrcypt and decrypt team password' do
      encrypted_password = CryptUtils.encrypt_rsa(@team_password, @public_key)
      decrypted_password = CryptUtils.decrypt_rsa(encrypted_password, @private_key)
      expect(@team_password).to eq(decrypted_password)
    end
  end

  context 'private key' do
    it 'should encrypt and decrypt private key' do
      encrypted_private_key = CryptUtils.encrypt_private_key(@private_key, @password)
      decrypted_private_key = CryptUtils.decrypt_private_key(encrypted_private_key, @password)
      expect(@private_key).to eq(decrypted_private_key)
    end

    it 'should encrypt and decrypt private key with pk_secret' do
      expect(Keycloak::Client).to receive(:get_attribute).with('pk_secret_base').and_return(nil)
      pk_secret = CryptUtils.pk_secret(SecureRandom.base64(32))
      encrypted_private_key = CryptUtils.encrypt_private_key(@private_key, pk_secret)
      decrypted_private_key = CryptUtils.decrypt_private_key(encrypted_private_key, pk_secret)
      expect(@private_key).to eq(decrypted_private_key)
    end
  end

  context 'key pair' do
    it 'should not raise exception if valid keypair' do
      CryptUtils.validate_keypair(@private_key, @public_key)
    end

    it 'should raise expection if keypair does not match' do
      public_key = CryptUtils.extract_public_key(CryptUtils.new_keypair)
      expect do
        CryptUtils.validate_keypair(@private_key, public_key)
      end.to raise_error(Exceptions::DecryptFailed)
    end
  end

  context 'blob data' do
    it 'should encrypt and decrypt blob data' do
      blob_data = Base64.decode64('test')
      blob_data_encrypted = CryptUtils.encrypt_blob(blob_data, @team_password)
      result = CryptUtils.decrypt_blob(blob_data_encrypted, @team_password)
      expect(blob_data.force_encoding('UTF-8')).to eq(result)
    end
  end
end
