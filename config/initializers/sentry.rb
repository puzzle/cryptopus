# frozen_string_literal: true

Raven.configure do |config|

  # exclude the following exceptions:
  config.excluded_exceptions += %w[Mysql2::Error::ConnectionError]

  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
end
