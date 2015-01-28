require 'rails_helper'

describe CryptUtils do

  before(:each) do
    @password = 'foo password'
    @team_password = CryptUtils.new_team_password
    keypair = CryptUtils.new_keypair
    @private_key = CryptUtils.get_private_key_from_keypair(keypair)
    @public_key = CryptUtils.get_public_key_from_keypair(keypair) 
  end

  describe "#one_way_crypt" do
    it "should create SHA1 password hash" do
      sha1hash = 'f79b1011916180fead65ac4e199dd607e89fa411'
      expect(CryptUtils.one_way_crypt(@password)).to eq(sha1hash)
    end
  end

  describe "team password" do
    it "should enrcypt and decrypt team password" do
      encrypted_password = CryptUtils.encrypt_team_password(@team_password, @public_key)
      decrypted_password = CryptUtils.decrypt_team_password(encrypted_password, @private_key)
      expect(decrypted_password).to eq(@team_password)
    end
  end

  describe "private key" do
    it "should encrypt and decrypt private key" do
      encrypted_private_key = CryptUtils.encrypt_private_key(@private_key, @password)
      decrypted_private_key = CryptUtils.decrypt_private_key(encrypted_private_key, @password)
      expect(decrypted_private_key).to eq (@private_key)
    end
  end

  describe "key pair" do
    it "should not raise exception if valid keypair" do
      CryptUtils.validate_keypair(@private_key, @public_key)
    end

    it "should raise expection if keypair does not match" do
      public_key = CryptUtils.get_public_key_from_keypair(CryptUtils.new_keypair)
      expect { CryptUtils.validate_keypair(@private_key, public_key) }.to raise_error(Exceptions::DecryptFailed)
    end
  end

  describe "blob data" do
    it "should encrypt and decrypt blob data" do
      blob_data = Base64.decode64("test")
      blob_data_encrypted = CryptUtils.encrypt_blob( blob_data, @team_password)
      result = CryptUtils.decrypt_blob( blob_data_encrypted, @team_password )
      expect( result ).to eq( blob_data )
    end
  end

end
