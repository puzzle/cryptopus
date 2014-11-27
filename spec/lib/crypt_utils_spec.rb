require 'rails_helper'

describe CryptUtils do

  before(:each) do
    @password = 'foo password'
  end

  describe "#one_way_crypt" do
    it "should create SHA1 password hash" do
      sha1hash = 'f79b1011916180fead65ac4e199dd607e89fa411'
      expect(CryptUtils.one_way_crypt(@password)).to eq(sha1hash)
    end
  end


end
