# Copyright (c) 2007 Puzzle ITC GmbH. All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'openssl'
require 'digest/sha1'

include OpenSSL

class CryptUtilsLegacy

  def CryptUtilsLegacy.decrypt_private_key( private_key, password )
      cipher = OpenSSL::Cipher::Cipher.new( 'aes-256-cbc' )
      cipher.decrypt
      cipher.key = password.unpack( 'a2'*32 ).map{|x| x.hex}.pack( 'c'*32 )
      decrypted_private_key = cipher.update( private_key )
      decrypted_private_key << cipher.final()
  end
end

