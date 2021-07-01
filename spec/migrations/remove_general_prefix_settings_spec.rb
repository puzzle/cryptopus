# frozen_string_literal: true

require 'spec_helper'

mig_file = Dir[Rails.root.join('db/migrate/20210701121708_remove_general_prefix_settings.rb')].first
require mig_file

describe RemoveGeneralPrefixSettings do

  let(:migration) { RemoveGeneralPrefixSettings.new }

  def silent
    verbose = ActiveRecord::Migration.verbose = false

    yield

    ActiveRecord::Migration.verbose = verbose
  end

  around do |test|
    silent { test.run }
  end

  context 'up' do
    before { migration.down }

    it 'removes general key prefix from existing settings' do
      expect(Setting.exists?(key: 'general_country_source_whitelist')).to eq true
      expect(Setting.exists?(key: 'general_ip_whitelist')).to eq true
      expect(Setting.count).to eq 2

      migration.up

      expect(Setting.exists?(key: 'country_source_whitelist')).to eq true
      expect(Setting.exists?(key: 'ip_whitelist')).to eq true
      expect(Setting.exists?(key: 'general_country_source_whitelist')).to eq false
      expect(Setting.exists?(key: 'general_ip_whitelist')).to eq false
      expect(Setting.count).to eq 2
    end

    it 'has just new settings' do
      migration.up

      expect(Setting.exists?(key: 'country_source_whitelist')).to eq true
      expect(Setting.exists?(key: 'ip_whitelist')).to eq true
      expect(Setting.count).to eq 2
    end

    it 'deletes old settings if new settings already exist' do
      Setting.create!(
        key: 'country_source_whitelist',
        value: %w[CH DE],
        type: Setting::CountryCode
      )
      Setting.create!(
        key: 'ip_whitelist',
        value: %w[0.0.0.0 192.168.10.0],
        type: Setting::IpRange
      )

      expect(Setting.exists?(key: 'country_source_whitelist')).to eq true
      expect(Setting.exists?(key: 'ip_whitelist')).to eq true
      expect(Setting.exists?(key: 'general_country_source_whitelist')).to eq true
      expect(Setting.exists?(key: 'general_ip_whitelist')).to eq true
      expect(Setting.count).to eq 4

      migration.up

      expect(Setting.exists?(key: 'country_source_whitelist')).to eq true
      expect(Setting.exists?(key: 'ip_whitelist')).to eq true
      expect(Setting.count).to eq 2
    end
  end

  context 'down' do
    it 'has new settings and should be changed to old settings' do
      migration.up

      expect(Setting.exists?(key: 'country_source_whitelist')).to eq true
      expect(Setting.exists?(key: 'ip_whitelist')).to eq true
      expect(Setting.count).to eq 2

      migration.down

      expect(Setting.exists?(key: 'general_country_source_whitelist')).to eq true
      expect(Setting.exists?(key: 'general_ip_whitelist')).to eq true
    end
  end
end
