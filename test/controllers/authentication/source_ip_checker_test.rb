# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class SourceIpCheckerTest <  ActiveSupport::TestCase

  test 'allows if previously authorized' do
    checker = Authentication::SourceIpChecker.new('132.120.23.21')

    assert_equal true, checker.previously_authorized?('132.120.23.21')
  end
  
  test 'allows private ips' do
    private_ips = ["10.#{rand(254)}.#{rand(254)}.#{rand(254)}",
                   "192.168.#{rand(254)}.#{rand(254)}",
                   "172.#{rand(16..31)}.#{rand(254)}.#{rand(254)}",
                   "127.#{rand(254)}.#{rand(254)}.#{rand(254)}"]

    private_ips.each do |ip|
      Authentication::SourceIpChecker.any_instance.stubs(:remote_ip).returns(ip)
      checker = Authentication::SourceIpChecker.new(ip)
      assert_equal true, checker.send(:private_ip?)
      assert_equal true, checker.ip_authorized?
    end
  end

  test 'does not allow ip if unknown location' do
    country = mock()
    country.expects(:country_code2).returns('--')
    GeoIP.any_instance.expects(:country).returns(country)

    checker = Authentication::SourceIpChecker.new('1.42.42.12')

    assert_equal false, checker.ip_authorized?
  end

  test 'does not allow ip if country is not whitelisted' do
    checker = Authentication::SourceIpChecker.new('8.8.8.8')
    assert_equal false, checker.send(:country_authorized?)
    assert_equal false, checker.ip_authorized?
  end

  test 'allows ip from whitelisted country' do
    ch_ip = '46.140.0.1'

    checker = Authentication::SourceIpChecker.new(ch_ip)
    assert_equal true, checker.send(:country_authorized?)
    assert_equal true, checker.ip_authorized?
  end

  test 'allows whitelisted ip' do
    Setting.find_by(key: 'general_ip_whitelist').update!(value: ['132.120.23.21'])

    checker = Authentication::SourceIpChecker.new('132.120.23.21')
    assert_equal true, checker.send(:ip_whitelisted?)
    assert_equal true, checker.ip_authorized?
  end

  test 'allows whitelisted ip in range' do
    ip = "132.#{rand(254)}.#{rand(254)}.#{rand(254)}"
    Setting.find_by(key: 'general_ip_whitelist').update!(value: ['132.0.0.0/8'])

    checker = Authentication::SourceIpChecker.new(ip)
    assert_equal true, checker.send(:ip_whitelisted?)
    assert_equal true, checker.ip_authorized?
  end

  test 'raises error if geo dat file missing' do
    File.expects(:exist?).returns(false)
    ch_ip = '46.140.0.1'

    Authentication::SourceIpChecker.any_instance.stubs(:private_ip?).returns(false)
    Authentication::SourceIpChecker.any_instance.stubs(:remote_ip).returns(ch_ip)

    checker = Authentication::SourceIpChecker.new(ch_ip)
    exception = assert_raises(RuntimeError) do
      checker.ip_authorized?
    end

    assert_match /run rake geo:fetch/, exception.message
  end

end
