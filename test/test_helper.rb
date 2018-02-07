# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

ENV['RAILS_ENV'] ||= 'test'

require 'simplecov'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/autorun"
require 'mocha/mini_test'
require "minitest/rails/capybara"
require 'policies/policy_test'

ActiveRecord::Migration.maintain_test_schema!

Dir[Rails.root.join('test/support/**/*.rb')].sort.each { |f| require f }

SimpleCov.start 'rails' do
  add_filter 'lib/ldap_connection.rb'
  add_filter 'app/helpers'
  coverage_dir 'test/coverage'
end

Capybara.default_max_wait_time = 5

Capybara::Webkit.configure do |config|
  config.debug = false
  config.allow_unknown_urls
end


class ActiveSupport::TestCase

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  def decrypt_private_key(user)
    user.decrypt_private_key('password')
  end

  def legacy_encrypt_private_key(private_key, password)
    cipher = OpenSSL::Cipher::Cipher.new( "aes-256-cbc" )
    cipher.encrypt
    cipher.key = password.unpack( 'a2'*32 ).map{|x| x.hex}.pack( 'c'*32 )
    encrypted_private_key = cipher.update( private_key )
    encrypted_private_key << cipher.final()
    encrypted_private_key
  end

  def enable_ldap
    Setting.find_by(key: 'ldap_enable').update!(value: true)
  end

  def self.context(title, &block)
    yield
  end

end

class Capybara::Rails::TestCase
  self.use_transactional_tests = false
  DatabaseCleaner.strategy = :truncation

  setup do
    DatabaseCleaner.start
  end

  teardown { DatabaseCleaner.clean }
end
