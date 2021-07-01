# frozen_string_literal: true

require Rails.root.join('db', 'seeds', 'support', 'setting_seeder')

seeder = SettingSeeder.new

seeder.seed_setting(Setting::CountryCode, 'country_source_whitelist', [])
seeder.seed_setting(Setting::IpRange, 'ip_whitelist', [])
