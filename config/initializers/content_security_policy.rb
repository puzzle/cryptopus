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

  policy.default_src :none
  policy.font_src    :self
  policy.img_src     :self
  policy.connect_src :self, 'https://sentry.puzzle.ch'

  policy.script_src  :self
  policy.script_src  :self, :unsafe_eval, "http://localhost:4200" if Rails.env.development?

  policy.style_src   :self, :unsafe_inline
  policy.style_src   :self, :unsafe_inline, "http://localhost:4200" if Rails.env.development?

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
