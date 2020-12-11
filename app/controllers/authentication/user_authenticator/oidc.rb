# frozen_string_literal: true

class Authentication::UserAuthenticator::Oidc < Authentication::UserAuthenticator

  def authenticate!(code:, state:)
    raise 'openid connect auth not enabled' unless AuthConfig.oidc_enabled?

    @code = code
    @state = state

    params_present? && user.present? && !user.root?
  end

  # only allow api users to authenticate by headers
  def authenticate_by_headers!
    authenticator = db_authenticator
    @user = authenticator.user
    if @user.is_a?(User::Api)
      return authenticator.authenticate_by_headers!
    end

    false
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
    user = User.find_by(username: oidc_username.strip)
    return if user&.is_a?(User::Api)

    user.presence || create_user
  end

  def oidc_user_params
    { username: oidc_username,
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
    if base.present? && base.length > 10
      true
    else
      raise 'openid connect id token: cryptopus_pk_secret_base not present or invalid'
    end
  end

  def oidc_username
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
