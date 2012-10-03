# Put this in config/application.rb
require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(:default, Rails.env) if defined?(Bundler)

module Cryptopus
  class Application < Rails::Application
    config.autoload_paths += [config.root.join('lib')]
    config.encoding = 'utf-8'
    config.filter_parameters += [:password, :private_key]
    config.assets.enabled = true
    config.time_zone = 'UTC'
  end
end
