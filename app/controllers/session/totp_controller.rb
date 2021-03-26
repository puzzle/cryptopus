# frozen_string_literal: true

class Session::TotpController < SessionController
  before_action :redirect_to_root, unless: :two_factor_authentication_pending?
  skip_before_action :redirect_if_no_private_key, only: [:destroy, :new, :create]

  layout 'session', only: :new

  def create
    unless totp_authenticator.authenticate!
      flash[:error] = t('flashes.session.auth_failed')
      return redirect_to session_totp_new_path
    end

    last_login_message

    session.delete(:two_factor_authentication_user_id)
    redirect_after_sucessful_login
  end

  private

  def authorize_action
    authorize :totp
  end

  def redirect_to_root
    redirect_to root_path
  end

  def totp_authenticator
    Authentication::UserAuthenticator::Totp.new(totp_code: params[:totp_code], session: session)
  end
end
