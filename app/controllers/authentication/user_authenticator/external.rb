# frozen_string_literal: true

class Authentication::UserAuthenticator::External < Authentication::UserAuthenticator
  def create_user(user_params, password)
    User::Human.create(user_params) do |u|
      u.username = username
      u.auth = self.class.name.demodulize.downcase
      u.create_keypair(password)
    end
  end

  def update_user_info(params)
    user.update(params)
  end
end
