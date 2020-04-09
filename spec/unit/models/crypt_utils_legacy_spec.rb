# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'
describe CryptUtilsLegacy do
  it 'decrypts legacy private key' do
    encrypted_private_key = users(:bob).private_key
    decrypted_private_key = CryptUtils.decrypt_private_key(encrypted_private_key, 'password')
    legacy_encrypted_private_key = legacy_encrypt_private_key(decrypted_private_key, 'password')
    legacy_decrypted_private_key = CryptUtilsLegacy.decrypt_private_key(
      legacy_encrypted_private_key, 'password'
    )

    expect(legacy_decrypted_private_key).to eq(decrypted_private_key)
  end
end
