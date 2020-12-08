# frozen_string_literal: true

# OpenID Connect Client

class OidcClient

  include Rails.application.routes.url_helpers

  def user_signed_in?
  end

  def external_login_url(jump_to: nil)
    client.redirect_uri = cryptopus_redirect_uri(jump_to: jump_to)
    client.authorization_uri
  end

  def get_attribute(attr, access_token)
  end

  private

  def client
    @client ||= init_client
  end

  def init_client
    OpenIDConnect::Client.new(
      identifier: config[:client_id],
      secret: config[:secret],
      host: config[:host],
      authorization_endpoint: config[:authorization_endpoint],
      token_endpoint: config[:token_endpoint]
    )
  end

  def config
    AuthConfig.oidc_settings
  end

  def cryptopus_redirect_uri(jump_to: nil)
    params = {}
    params[:jump_to] = jump_to if jump_to.present?

    protocol = Rails.application.config.force_ssl ? 'https://' : 'http://'
    protocol + (ENV['RAILS_HOST_NAME'] || 'localhost:3000') + oidc_path(params)
  end

end
