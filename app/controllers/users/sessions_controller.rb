# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params, only: [:create]
  # it's save to disable this for authenticate since there is no logged in session active
  # in this case.
  # caused problem with login form since the server side session is getting invalid after
  # configured timeout.
  skip_before_action :verify_authenticity_token
  before_action :skip_authorization

  # GET /resource/sign_in
  # def new
  #   super
  # end


  def create
    user = User.find_by(username: username)
    if user.auth_db?
      super
    elsif user.auth == 'ldap'
      authenticator.auth!
      @user.sign_in(User, user)
    end
    session[:private_key] = @user.decrypt_private_key(password)
    check_password_strength
    last_login_message
  rescue StandardError
    flash[:error] = t('flashes.logins.auth_failed')
    redirect_to new_user_session_path
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:username])
  end

  private

  def username
    params[:user][:username]
  end

  def password
    params[:user][:password]
  end

  def authenticator
    Authentication::UserAuthenticator.new(username: username, password: password)
  end

  def last_login_message
    flash_message = Flash::LastLoginMessage.new(@user)
    flash[:notice] = flash_message.message if flash_message
  end

  def check_password_strength
    strength = PasswordStrength.test(username, password)

    if strength.weak? || !strength.valid?
      flash[:alert] = t('flashes.logins.weak_password')
    end
  end
end
