# frozen_string_literal: true

class Authentication::UserAuthenticator::Totp < Authentication::UserAuthenticator

  def initialize(totp_code: nil, session: nil)
    @totp_code = totp_code
    @session = session
  end

  def authenticate!(params = {})
    super(params)

    !!otp.verify(totp_code)
  end

  private

  attr_reader :totp_code

  # db users can't be created automatically so only find
  def find_or_create_user
    User.find(@session[:two_factor_authentication_user_id])
  end

  def otp
    OneTimePassword.new(user.username)
  end
end
