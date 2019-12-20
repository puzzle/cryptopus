# encoding: utf-8

#  Copyright (c) 2008-2019, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

namespace :setting do
  desc 'Get ldap_hostname'
  task get_ldap_hostname: :environment do
    pp Setting.find_by(key: "ldap_hostname").value
  end

  desc 'Set ldap_hostname: `rake setting:set_ldap_hostname[\'yourdomain.com yourdomain2.com\']`'
  task :set_ldap_hostname, [:value] =>  :environment do |task, args|
    unless args.value
      puts "ERROR: at least one hostname is required"
      exit 1
    end
    setting = Setting.find_by(key: "ldap_hostname")
    setting.value = args.value.split(" ")
    setting.save!
  end
end
