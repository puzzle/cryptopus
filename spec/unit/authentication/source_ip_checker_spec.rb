# frozen_string_literal: true

require 'rails_helper'

describe Authentication::SourceIpChecker do
  it 'allows if previously authorized' do
    checker = Authentication::SourceIpChecker.new('132.120.23.21')

    expect(checker.previously_authorized?('132.120.23.21')).to eq true
  end

  it 'allows private ips' do
    private_ips = ["10.#{rand(254)}.#{rand(254)}.#{rand(254)}",
                   "192.168.#{rand(254)}.#{rand(254)}",
                   "172.#{rand(16..31)}.#{rand(254)}.#{rand(254)}",
                   "127.#{rand(254)}.#{rand(254)}.#{rand(254)}"]

    private_ips.each do |ip|
      checker = Authentication::SourceIpChecker.new(ip)
      expect(checker).to receive(:remote_ip).exactly(2).times.and_return(ip)
      expect(checker.send(:private_ip?)).to be true
      expect(checker.ip_authorized?).to be true
    end
  end

  it 'does not allow ip if unknown location' do
    expect(GeoIp).to receive(:activated?).and_return(true).at_least(:once)
    checker = Authentication::SourceIpChecker.new('1.42.42.12')
    mock_geo_ip(checker, '')
    expect(checker.ip_authorized?).to eq false
  end

  it 'does not allow ip if country is not whitelisted' do
    expect(GeoIp).to receive(:activated?).and_return(true).at_least(:once)
    checker = Authentication::SourceIpChecker.new('8.8.8.8')
    mock_geo_ip(checker, 'US')
    expect(checker.send(:country_authorized?)).to eq false
    expect(checker.ip_authorized?).to eq false
  end

  it 'allows ip from whitelisted country' do
    expect(GeoIp).to receive(:activated?).and_return(true).at_least(:once)
    ch_ip = '46.140.0.1'
    checker = Authentication::SourceIpChecker.new(ch_ip)
    mock_geo_ip(checker, 'CH')
    expect(checker.send(:country_authorized?)).to eq true
    expect(checker.ip_authorized?).to eq true
  end

  it 'allows whitelisted ip' do
    expect(GeoIp).to receive(:activated?).and_return(true).at_least(:once)
    Setting.find_by(key: 'general_ip_whitelist').update!(value: ['132.120.23.21'])

    checker = Authentication::SourceIpChecker.new('132.120.23.21')
    expect(checker.send(:ip_whitelisted?)).to eq true
    expect(checker.ip_authorized?).to eq true
  end

  it 'allows whitelisted ip in range' do
    expect(GeoIp).to receive(:activated?).and_return(true).at_least(:once)
    ip = "132.#{rand(254)}.#{rand(254)}.#{rand(254)}"
    Setting.find_by(key: 'general_ip_whitelist').update!(value: ['132.0.0.0/8'])

    checker = Authentication::SourceIpChecker.new(ip)
    expect(checker.send(:ip_whitelisted?)).to eq true
    expect(checker.ip_authorized?).to eq true
  end

  it 'raises error if geo dat file missing and country whiteliste configured' do
    allow(GeoIp).to receive(:activated?).and_call_original

    db_file_path = Rails.root.join('db/geo_ip.mmdb')
    expect(File).to receive(:exist?).with(db_file_path).and_return(false).at_least(:once)
    ch_ip = '46.140.0.1'

    checker = Authentication::SourceIpChecker.new(ch_ip)
    expect do
      checker.ip_authorized?
    end.to raise_error(RuntimeError,
                       /https:\/\/github.com\/puzzle\/cryptopus\/wiki\/Geo-IP-Database/)
  end

  it 'authorizes without geo ip db and without country whitelist configured' do
    expect(GeoIp).to receive(:activated?).and_return(false)
    ip = '132.0.0.0'
    allow(Setting).to receive(:value).and_return([])
    checker = Authentication::SourceIpChecker.new(ip)
    expect(checker.ip_authorized?).to eq true
  end

  def mock_geo_ip(checker, country_code)
    geo_ip = double('geo_ip')
    expect(checker).to receive(:geo_ip).and_return(geo_ip).at_least(:once)
    allow(geo_ip).to receive(:country_code).and_return(country_code)
  end

end
