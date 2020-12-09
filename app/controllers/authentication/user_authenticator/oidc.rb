# frozen_string_literal: true

class Authentication::UserAuthenticator::Oidc < Authentication::UserAuthenticator

  def authenticate!(code:, state:)
    @code = code
    @state = state

    params_present? && not_root? && user.present? && no_brute_force_lock?
  end

  def authenticate_by_headers!
    return false unless header_preconditions?

    if user.is_a?(User::Api)
      authenticated = user.authenticate_db(password)
    end
    brute_force_detector.update(authenticated)
    authenticated
  end

  def updatable_user_attrs
    oidc_user_params.slice(:givenname, :surname)
  end

  def login_path
    url, state = oidc_client.external_login_url
    @session[:oidc_state] = state
    url
  end

  def user_passphrase
    user_pk_secret_base = oidc_attrs['cryptopus_pk_secret_base']
    pk_secret_base = Rails.application.secrets.secret_key_base
    Digest::SHA512.hexdigest(user_pk_secret_base + pk_secret_base)
  end

  private

  def find_or_create_user
    user = User.find_by(username: username.strip)
    user.presence || create_user
  end

  def header_preconditions?
    headers_present? && user_valid? && !root_user?
  end

  def headers_present?
    username.present? && password.present?
  end

  def not_root?
    !root_user?
  end

  def oidc_user_params
    { username: username,
      provider_uid: oidc_attrs['sub'],
      givenname: oidc_attrs['given_name'],
      surname: oidc_attrs['family_name'] }
  end

  def create_user
    user_params = oidc_user_params
    user_params[:auth] = 'oidc'
    User::Human.create!(user_params) do |u|
      u.create_keypair(user_passphrase)
    end
  end

  def params_present?
    oidc_user_params.all?(&:present?) && valid_user_pk_secret_base?
  end

  def valid_user_pk_secret_base?
    base = oidc_attrs['cryptopus_pk_secret_base']
    base.present? && base.length > 10
  end

  def username
    oidc_attrs[oidc_client.user_subject]
  end

  def oidc_attrs
    @oidc_attrs ||= fetch_id_token.raw_attributes
  end

  def fetch_id_token
    oidc_client.get_id_token(code: @code, state: @state)
  end

  def oidc_client
    @oidc_client ||= OidcClient.new
  end
end
