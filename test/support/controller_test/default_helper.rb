module ControllerTest
  module DefaultHelper
    def login_as(username, password = 'password')
      user = User.find_by_username(username)
      request.session[:user_id] = user.id
      session[:private_key] = CryptUtils.decrypt_private_key( user.private_key, password )
    end
  end
end
