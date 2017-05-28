# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

#require_relative '../../../app/controllers/authentication/user_authenticator.rb'
#require_relative '../../../app/controllers/authentication/brute_force_detector.rb'
require 'test_helper'

class TwoFactorTest < ActiveSupport::TestCase

  test 'two factor auth is not required if setting disabled' do
    settings(:general_two_factor_auth).update!(value: false)

    remote_ip = '1.1.1.1'

    assert_equal false, two_factor_class.two_factor_required?(remote_ip)
  end

  test 'two factor auth is not required for whitelisted ip' do
    remote_ip = '192.168.22.42'

    assert_equal true, two_factor_class.two_factor_required?(remote_ip)
  end

  test 'two factor auth is required for non whitelisted ip' do
    remote_ip = '1.1.1.1'

    assert_equal true, two_factor_class.two_factor_required?(remote_ip)
  end

  private

  def two_factor_class
    Authentication::Authenticators::TwoFactor
  end

end
