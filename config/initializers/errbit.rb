# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

if defined?(Airbrake)

  Airbrake.configure do |config|
    # if no host is given, ignore all environments
    config.environment = Rails.env
    config.ignore_environments = [:development, :test]
    config.ignore_environments << :production if ENV['RAILS_AIRBRAKE_HOST'].blank?

    config.project_id     = 1 # required, but any positive integer works
    config.project_key    = ENV['RAILS_AIRBRAKE_API_KEY']
    config.host           = ENV['RAILS_AIRBRAKE_HOST']
    config.blacklist_keys << 'RAILS_DB_PASSWORD'
    config.blacklist_keys << 'RAILS_AIRBRAKE_API_KEY'
    config.blacklist_keys << 'RAILS_SECRET_TOKEN'
    config.blacklist_keys << /password/i
  end

  ignored_exceptions = %w(ActionController::MethodNotAllowed
                          ActionController::RoutingError
                          ActionController::UnknownHttpMethod)

  Airbrake.add_filter do |notice|
    if (notice[:errors].map { |e| e[:type] } & ignored_exceptions).present?
      notice.ignore!
    end
  end

else # defined?(Airbrake)

  # Create stub module for development and test
  module Airbrake
    extend self

    def notify(*args)
    end
  end

end # defined?(Airbrake)
