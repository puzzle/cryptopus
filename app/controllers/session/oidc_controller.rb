# frozen_string_literal: true

class Session::OidcController < SessionController

  before_action :validate_state

  def create
    fetch_token

    unless user_authenticator.authenticate!
      return redirect_to user_authenticator.keycloak_login
    end

    unless create_session(oidc_client.user_pk_secret(nil, access_token))
      return redirect_if_decryption_error
    end

    redirect_after_sucessful_login
  end

  private

  # use openid state for csrf protection
  def validate_state
    if state_invalid?
      raise 'openid connect csrf protection state invalid'
    end
  end

  def state_invalid?
    state = session.delete(:oidc_state)
    state != params[:state]
  end

  def fetch_token
    code = params[:code]
    state = params[:state]
    if code.present?
      token = oidc_client.get_token_from_provider(
        code: code, state: state
      )
      @oidc_token = token
    end
  end

  def redirect_if_decryption_error
    if current_user.oidc?
      reset_session_before_redirect
      redirect_to user_authenticator.keycloak_login
    else

    end
    return redirect_to user_authenticator.recrypt_path unless current_user.keycloak?

  end

  def authorize_action
    authorize :oidc, policy_class: SessionPolicy
  end

  def reset_session_before_redirect
    jumpto = params[:jumpto]
    reset_session
    session[:jumpto] = jumpto
  end

  def user_password
    user_pk_secret_base = @oidc_token[:cryptopus_pk_secret_base]
    pk_secret_base = Rails.application.secrets.secret_key_base
    Digest::SHA512.hexdigest(user_pk_secret_base + pk_secret_base)
  end
end
