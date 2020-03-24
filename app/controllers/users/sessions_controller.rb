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
    username = params[:user][:username]
    user = User.find_by(username: username)
    if user.present?
      if user.auth_db?
        super
        session[:private_key] = @user.decrypt_private_key(params[:user][:password])
      elsif AuthConfig.ldap_enabled? && user.auth == 'ldap'
        @user = User::Human.find_or_import_from_ldap(username.strip, password)
        @user.sign_in(User, user)
        session[:private_key] = @user.decrypt_private_key(params[:user][:password])
      end
    else
      flash[:error] = t('flashes.logins.auth_failed')
      redirect_to new_user_session_path
    end
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
end
