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
    GeoIp.expects(:activated?).returns(true).at_least_once
    checker = Authentication::SourceIpChecker.new('1.42.42.12')
    mock_geo_ip(checker, '')
    assert_equal false, checker.ip_authorized?
  end

  test 'does not allow ip if country is not whitelisted' do
    GeoIp.expects(:activated?).returns(true).at_least_once
    checker = Authentication::SourceIpChecker.new('8.8.8.8')
    mock_geo_ip(checker, 'US')
    assert_equal false, checker.send(:country_authorized?)
    assert_equal false, checker.ip_authorized?
  end

  test 'allows ip from whitelisted country' do
    GeoIp.expects(:activated?).returns(true).at_least_once
    ch_ip = '46.140.0.1'
    checker = Authentication::SourceIpChecker.new(ch_ip)
    mock_geo_ip(checker, 'CH')
    assert_equal true, checker.send(:country_authorized?)
    assert_equal true, checker.ip_authorized?
  end

  test 'allows whitelisted ip' do
    GeoIp.expects(:activated?).returns(true).at_least_once
    Setting.find_by(key: 'general_ip_whitelist').update!(value: ['132.120.23.21'])

    checker = Authentication::SourceIpChecker.new('132.120.23.21')
    assert_equal true, checker.send(:ip_whitelisted?)
    assert_equal true, checker.ip_authorized?
  end

  test 'allows whitelisted ip in range' do
    GeoIp.expects(:activated?).returns(true).at_least_once
    ip = "132.#{rand(254)}.#{rand(254)}.#{rand(254)}"
    Setting.find_by(key: 'general_ip_whitelist').update!(value: ['132.0.0.0/8'])

    checker = Authentication::SourceIpChecker.new(ip)
    assert_equal true, checker.send(:ip_whitelisted?)
    assert_equal true, checker.ip_authorized?
  end

  test 'raises error if geo dat file missing and country whiteliste configured' do
    db_file_path = Rails.root.join('db', 'geo_ip.mmdb')
    File.expects(:exist?).with(db_file_path).returns(false).at_least_once
    ch_ip = '46.140.0.1'

    checker = Authentication::SourceIpChecker.new(ch_ip)
    exception = assert_raises(RuntimeError) do
      checker.ip_authorized?
    end

    assert_includes exception.message, 'https://github.com/puzzle/cryptopus/wiki/Geo-IP-Database'
  end

  test 'authorizes without geo ip db and without country whitelist configured' do
    GeoIp.expects(:activated?).returns(false)
    ip = "132.0.0.0"
    Setting.stubs(:value).returns([])
    checker = Authentication::SourceIpChecker.new(ip)
    assert_equal true, checker.ip_authorized?
  end

  def mock_geo_ip(checker, country_code)
    geo_ip = mock('geo_ip');
    checker.expects(:geo_ip).returns(geo_ip).at_least_once
    geo_ip.stubs(:country_code).returns(country_code)
  end

end
