# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

Rails.application.config.content_security_policy do |policy|
  # Attributes clarification
  # :self, only allow resources from current origin
  # :none, won't allow loading of any resources
  #
  # :https, allow loading resources from arbitrary hosts that are protected by https
  #
  # :unsafe_eval, allows execution of eval statements
  # :unsafe_inline, allows inline resources usage
  FRONTEND_URL = 'http://localhost:4200'

  policy.default_src :none unless Rails.env.development?
  policy.font_src    :self, "http://localhost:4200/text-security-disc-compat.eot?#iefix",
                            "http://localhost:4200/text-security-disc.woff2",
                            "http://localhost:4200/text-security-disc-compat.ttf"
  policy.img_src     :self
  policy.connect_src :self, 'https://sentry.puzzle.ch'

  policy.font_src :self
  policy.font_src :self, :https, FRONTEND_URL, :data if Rails.env.development?

  policy.script_src  :self
  policy.script_src  :self, :unsafe_eval, FRONTEND_URL if Rails.env.development?

  policy.style_src   :self, :unsafe_inline
  policy.style_src   :self, :unsafe_inline, FRONTEND_URL if Rails.env.development?

  # If you are using webpack-dev-server then specify webpack-dev-server host
  policy.connect_src :self, "http://localhost:3035", "ws://localhost:4200" if Rails.env.development?

  # Specify URI for violation reports
  policy.report_uri ENV.fetch('SENTRY_REPORT_URI', '') unless Rails.env.development?
end

# If you are using UJS then enable automatic nonce generation
Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }

# Set the nonce only to specific directives
Rails.application.config.content_security_policy_nonce_directives = %w(script-src)

# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
# Rails.application.config.content_security_policy_report_only = true
