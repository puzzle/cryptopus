# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
require 'geokit'

class SourceIpCheckerTest <  ActiveSupport::TestCase

  test 'allows if previously authorized' do
    Authentication::SourceIpChecker.any_instance.stubs(:remote_ip).returns('132.120.23.21')
    checker = Authentication::SourceIpChecker.new('stubbed', '132.120.23.21')

    assert_equal true, checker.previously_authorized?
  end
  
  test 'allows private ips' do
    private_ips = ["10.#{rand(254)}.#{rand(254)}.#{rand(254)}",
                   "192.168.#{rand(254)}.#{rand(254)}",
                   "172.#{rand(16..31)}.#{rand(254)}.#{rand(254)}",
                   "127.#{rand(254)}.#{rand(254)}.#{rand(254)}"]

    private_ips.each do |ip|
      Authentication::SourceIpChecker.any_instance.stubs(:remote_ip).returns(ip)
      checker = Authentication::SourceIpChecker.new(ip, nil)
      assert_equal true, checker.send(:private_ip?)
      assert_equal true, checker.ip_authorized?
    end
  end

  test 'does not allow ip if unknown location' do
    Authentication::SourceIpChecker.any_instance.stubs(:private_ip?).returns(false)
    Geokit::GeoLoc.any_instance.stubs(:country_code).returns(nil)

    checker = Authentication::SourceIpChecker.new(random_ip, nil)
    assert_not checker.ip_authorized?
  end

  test 'does not allow ip if country is not whitelisted' do
    Authentication::SourceIpChecker.any_instance.stubs(:private_ip?).returns(false)
    Geokit::GeoLoc.any_instance.stubs(:country_code).returns('US')

    checker = Authentication::SourceIpChecker.new(random_ip, nil)
    assert_not checker.send(:country_authorized?)
    assert_not checker.ip_authorized?
  end

  test 'allows ip from whitelisted country' do
    Authentication::SourceIpChecker.any_instance.stubs(:private_ip?).returns(false)
    Geokit::GeoLoc.any_instance.stubs(:country_code).returns('CH')

    checker = Authentication::SourceIpChecker.new(random_ip, nil)
    assert_equal true, checker.send(:country_authorized?)
    assert_equal true, checker.ip_authorized?
  end

  test 'allows whitelisted ip' do
    Setting.find_by(key: 'general_ip_whitelist').update!(value: ['132.120.23.21'])

    Authentication::SourceIpChecker.any_instance.stubs(:private_ip?).returns(false)
    Authentication::SourceIpChecker.any_instance.stubs(:remote_ip).returns('132.120.23.21')

    checker = Authentication::SourceIpChecker.new('132.120.23.21', nil)
    assert_equal true, checker.send(:ip_whitelisted?)
    assert_equal true, checker.ip_authorized?
  end

  test 'allows whitelisted ip in range' do
    ip = "132.#{rand(254)}.#{rand(254)}.#{rand(254)}"
    Setting.find_by(key: 'general_ip_whitelist').update!(value: ['132.0.0.0/8'])

    Authentication::SourceIpChecker.any_instance.stubs(:private_ip?).returns(false)
    Authentication::SourceIpChecker.any_instance.stubs(:remote_ip).returns(ip)

    checker = Authentication::SourceIpChecker.new(ip, nil)
    assert_equal true, checker.send(:ip_whitelisted?)
    assert_equal true, checker.ip_authorized?
  end

  private

  def random_ip
    "#{rand(253)+1}.#{rand(254)}.#{rand(254)}.#{rand(254)}"
  end

end
