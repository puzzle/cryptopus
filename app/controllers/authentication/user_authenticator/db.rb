# frozen_string_literal: true

class Authentication::UserAuthenticator::Db < Authentication::UserAuthenticator

  def authenticate!(params = {})
    super(**params)
    return false unless preconditions?

    authenticated = user.authenticate_db(password)

    brute_force_detector.update(authenticated)
    authenticated
  end

  # nothing to update since all attrs are in db
  def updatable_user_attrs
    {}
  end

  private

  # db users can't be created automatically so only find
  def find_or_create_user
    User.find_by(username: username.strip, auth: 'db')
  end
end
