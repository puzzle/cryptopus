# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'openssl'
require 'digest/sha1'

include OpenSSL

class CryptUtilsLegacy

  def self.decrypt_private_key(private_key, password)
    cipher = OpenSSL::Cipher::Cipher.new('aes-256-cbc')
    cipher.decrypt
    cipher.key = password.unpack('a2' * 32).map { |x| x.hex }.pack('c' * 32)
    decrypted_private_key = cipher.update(private_key)
    decrypted_private_key << cipher.final
  end
end
