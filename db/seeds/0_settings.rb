# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require Rails.root.join('db', 'seeds', 'support', 'setting_seeder')

seeder = SettingSeeder.new

seeder.seed_text_setting('ldap_basename', 'ou=users,dc=yourdomain,dc=com')
seeder.seed_setting(:Host, 'ldap_hostname', ['yourdomain.com'])
seeder.seed_number_setting('ldap_portnumber', '636')
seeder.seed_text_setting('ldap_encryption', 'simple_tls')
seeder.seed_text_setting('ldap_bind_password', '')
seeder.seed_true_false_setting('ldap_enable', 'f')

seeder.seed_setting(:CountryCode,'general_country_source_whitelist', [])
seeder.seed_setting(:IpRange, 'general_ip_whitelist', [])
