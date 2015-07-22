  class UserFixtureCrypt
    attr_reader :public_key, :private_key, :password

    def initialize(password)
      @password = CryptUtils.one_way_crypt(password)
      keypair = CryptUtils.new_keypair
      uncrypted_private_key = CryptUtils.get_private_key_from_keypair(keypair)
      @public_key = CryptUtils.get_public_key_from_keypair(keypair)
      @private_key = CryptUtils.encrypt_private_key(uncrypted_private_key, password)
    end
  end
