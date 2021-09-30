# Fixes https://github.com/nahi/httpclient/issues/445
# (Using openid_connect to talk to keycloak with Let's Encrypt certificate failed)

HTTPClient # make sure it's already loaded

class HTTPClient
  alias original_initialize initialize

  def initialize(*args, &block)
    original_initialize(*args, &block)
    # Force use of the default system CA certs (instead of the 6 year old bundled ones)
    @session_manager&.ssl_config&.set_default_paths
  end
end
