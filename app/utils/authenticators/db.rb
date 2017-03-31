module Authenticators
  class Db < Base

    private

    def authenticated?
      return authenticated_legacy? if legacy_password?
      authenticate_db
    end

    def authenticated_legacy?
      if legacy_authenticate
        update_legacy_password
        authenticate_db
      end
    end

    def legacy_authenticate
      @user.password == CryptUtils.legacy_one_way_crypt(@password)
    end

    def authenticate_db
      salt = @user.password.split('$')[1]
      @user.password.split('$')[2] == Digest::SHA512.hexdigest(salt + @password)
    end

    def legacy_password?
      @user.legacy_password?
    end

    def update_legacy_password
      @user.update_attribute(:password, hash_password)
    end

    def hash_password
      CryptUtils.one_way_crypt(@password)
    end

  end
end
