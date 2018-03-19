# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'


describe CryptUtils do

  before do
    @password = 'foo password'
    @team_password = CryptUtils.new_team_password
    keypair = CryptUtils.new_keypair
    @private_key = CryptUtils.extract_private_key(keypair)
    @public_key = CryptUtils.extract_public_key(keypair)
  end

  describe "#legacy_one_way_crypt" do
    it "should create SHA1 password hash" do
      sha1hash = 'f79b1011916180fead65ac4e199dd607e89fa411'
      assert_equal sha1hash, CryptUtils.legacy_one_way_crypt(@password)
    end
  end

  describe "#one_way_crypt" do
    it "should create SHA512 password hash" do
      hash = CryptUtils.one_way_crypt(@password)
      assert_match /^sha512\$.*\$.*/, hash
    end
  end

  describe "team password" do
    it "should enrcypt and decrypt team password" do
      encrypted_password = CryptUtils.encrypt_rsa(@team_password, @public_key)
      decrypted_password = CryptUtils.decrypt_rsa(encrypted_password, @private_key)
      assert_equal decrypted_password, @team_password
    end
  end

  describe "private key" do
    it "should encrypt and decrypt private key" do
      encrypted_private_key = CryptUtils.encrypt_private_key(@private_key, @password)
      decrypted_private_key = CryptUtils.decrypt_private_key(encrypted_private_key, @password)
      assert_equal decrypted_private_key, @private_key
    end
  end

  describe "key pair" do
    it "should not raise exception if valid keypair" do
      CryptUtils.validate_keypair(@private_key, @public_key)
    end

    it "should raise expection if keypair does not match" do
      public_key = CryptUtils.extract_public_key(CryptUtils.new_keypair)
      assert_raises(Exceptions::DecryptFailed) { CryptUtils.validate_keypair(@private_key, public_key) }
    end
  end

  describe "blob data" do
    it "should encrypt and decrypt blob data" do
      blob_data = Base64.decode64("test")
      blob_data_encrypted = CryptUtils.encrypt_blob( blob_data, @team_password)
      result = CryptUtils.decrypt_blob( blob_data_encrypted, @team_password )
      assert_equal result, blob_data.force_encoding('UTF-8')
    end
  end

end
