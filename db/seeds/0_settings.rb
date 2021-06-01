# frozen_string_literal: true

require Rails.root.join('db', 'seeds', 'support', 'setting_seeder')

seeder = SettingSeeder.new

seeder.seed_setting(Setting::CountryCode, 'general_country_source_whitelist', [])
seeder.seed_setting(Setting::IpRange, 'general_ip_whitelist', [])
