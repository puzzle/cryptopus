# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require Rails.root.join('db', 'seeds', 'support', 'setting_seeder')

seeder = SettingSeeder.new

seeder.seed_text_setting('ldap_basename', 'ou=users,dc=yourdomain,dc=com', 0)
seeder.seed_text_setting('ldap_hostname', 'yourdomain.com', 1)
seeder.seed_number_setting('ldap_portnumber', '636', 2)
seeder.seed_text_setting('ldap_encryption', 'simple_tls', 3)
seeder.seed_text_setting('ldap_bind_password', '', 4)
seeder.seed_true_false_setting('ldap_enable', 'f', 5)

seeder.seed_setting(:CountryCode,'general_country_source_whitelist', [], 0)
seeder.seed_setting(:IpRange, 'general_ip_whitelist', [], 0)
