# frozen_string_literal: true

class Session::OicdController < SessionController

  def create
    cookies.permanent[:oidc_token] = user_authenticator.token(params) if params[:code].present?

    unless user_authenticator.authenticate!
      return redirect_to user_authenticator.keycloak_login
    end

    unless create_session(oidc_client.user_pk_secret(nil, access_token))
      return redirect_if_decryption_error
    end

    redirect_after_sucessful_login
  end

  def inactive
    flash[:notice] = t('session.sso.inactive.inactive')
  end

  def self.policy_class
    Authentication::OicdPolicy
  end

  private

  def redirect_if_decryption_error
    return redirect_to user_authenticator.recrypt_path unless current_user.keycloak?

    reset_session_before_redirect
    redirect_to user_authenticator.keycloak_login
  end

  def authorize_action
    authorize :oidc
  end

  def reset_session_before_redirect
    jumpto = params[:jumpto]
    reset_session
    session[:jumpto] = jumpto
  end

  def keycloak_client
    @keycloak_client ||= KeycloakClient.new
  end

  def access_token
    return if cookies.nil? || cookies['keycloak_token'].nil?

    JSON.parse(cookies['keycloak_token']).try(:[], 'access_token')
  end
end
