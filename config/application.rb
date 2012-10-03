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
    config.action_controller.session = {
      :key => '_cryptopus_session',
      :secret      => 'c7b70e637f082ea9f091fea2728c5850fdb6a33f683a9513a10693eb9a0eb4ef6a6b08a2657e7b31c3b512db8bfaaa367e91600dfd1d6f9ece2667c5d8d84a58'
    }
  end
end
