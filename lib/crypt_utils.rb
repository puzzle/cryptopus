# $Id$

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

class CryptUtils

  def CryptUtils.one_way_crypt( password )
    return Digest::SHA1.hexdigest( password )
  end

  def CryptUtils.new_keypair
    keypair = PKey::RSA.new( 2048 )
    return keypair
  end
  
  def CryptUtils.get_private_key_from_keypair( keypair )
    return keypair.to_s()
  end
  
  def CryptUtils.get_public_key_from_keypair( keypair )
    return keypair.public_key.to_s()
  end

  def CryptUtils.decrypt_team_password( team_password, private_key )
    begin
      keypair = PKey::RSA.new( private_key )
      decrypted_team_password = keypair.private_decrypt( team_password )
      return decrypted_team_password
      
    rescue
      return nil
    end
  end
  
  def CryptUtils.encrypt_team_password( team_password, public_key )
    begin
      keypair = PKey::RSA.new( public_key )
      encrypted_team_password = keypair.public_encrypt( team_password )
      return encrypted_team_password
      
    rescue
      return nil
    end
  end
  
  def CryptUtils.new_team_password
    cipher = OpenSSL::Cipher::Cipher.new( "aes-256-cbc" )
    team_password = cipher.random_key()
    return team_password
  end
  
  def CryptUtils.encrypt_private_key( private_key, password )
    cipher = OpenSSL::Cipher::Cipher.new( "aes-256-cbc" )
    cipher.encrypt
    cipher.key = password.unpack( 'a2'*32 ).map{|x| x.hex}.pack( 'c'*32 )
    encrypted_private_key = cipher.update( private_key )
    encrypted_private_key << cipher.final()
    return encrypted_private_key
  end
  
  def CryptUtils.decrypt_private_key( private_key, password )
    cipher = OpenSSL::Cipher::Cipher.new( "aes-256-cbc" )
    cipher.decrypt
    cipher.key = password.unpack( 'a2'*32 ).map{|x| x.hex}.pack( 'c'*32 )
    decrypted_private_key = cipher.update( private_key )
    decrypted_private_key << cipher.final()
    return decrypted_private_key
  end
  
  def CryptUtils.encrypt_blob( blob, team_password )
    cipher = OpenSSL::Cipher::Cipher.new( "aes-256-cbc" )
    cipher.encrypt
    cipher.key = team_password
    crypted_blob = cipher.update( blob )
    crypted_blob << cipher.final()
    return crypted_blob
  end
  
  def CryptUtils.decrypt_blob( blob, team_password )
    cipher = OpenSSL::Cipher::Cipher.new( "aes-256-cbc" )
    cipher.decrypt
    cipher.key = team_password
    decrypted_blob = cipher.update( blob )
    decrypted_blob << cipher.final()
    return decrypted_blob
  end
  
end
