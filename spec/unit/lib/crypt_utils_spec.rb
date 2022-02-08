# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'spec_helper'


describe CryptUtils do

  before do
    @password = 'foo password'
    @team_password = CryptUtils.new_team_password
    keypair = Asymmetric.generate_new_keypair
    @private_key = keypair.to_s
    @public_key = keypair.public_key.to_s
  end


  context 'private key' do
    it 'should encrypt and decrypt private key' do
      encrypted_private_key = CryptUtils.encrypt_private_key(@private_key, @password)
      decrypted_private_key = CryptUtils.decrypt_private_key(encrypted_private_key, @password)
      expect(@private_key).to eq(decrypted_private_key)
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
