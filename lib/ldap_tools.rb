# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'net/ldap'

class LdapTools

  class << self
    # rubocop:disable MethodLength
    def ldap_login(username, password)
      return unless Setting.value(:ldap, :enable)
      check_username(username)

      # TODO
      ldap = Net::LDAP.new \
        host: Setting.value(:ldap, :hostname),
        port: Setting.value(:ldap, :portnumber),
        encryption: :simple_tls

      result = ldap.bind_as \
        base: Setting.value(:ldap, :basename),
        filter: "uid=#{username}",
        password: password

      if result
        user_dn = result.first.dn
        ldap = Net::LDAP.new \
          host: Setting.value(:ldap, :hostname),
          port: Setting.value(:ldap, :portnumber),
          encryption: :simple_tls,
          auth: { method: :simple,
                  username: user_dn,
                  password: password }

        if ldap.bind
          return true
        end
      end
      false
    end

    def get_uid_by_username(username)
      check_username(username)
      LdapTools.connect
      filter = Net::LDAP::Filter.eq('uid', username)
      @@ldap.search(base: Setting.value(:ldap, :basename), filter: filter,
                    attributes: ['uidnumber']) do |entry|
        entry.each do |attr, values|
          if attr.to_s == 'uidnumber'
            return values[0].to_s
          end
        end
      end
      raise 'UID of the user not found'
    end

    def get_ldap_info(uid, attribute)
      LdapTools.connect
      filter = Net::LDAP::Filter.eq('uidnumber', uid)
      @@ldap.search(base: Setting.value(:ldap, :basename), filter: filter,
                    attributes: [attribute]) do |entry|
        entry.each do |attr, values|
          if attr.to_s == attribute
            return values[0].to_s
          end
        end
      end
      "No <#{attribute} for uid #{uid}>"
    end

    def connect
      return unless Setting.value(:ldap, :enable)

      @@ldap = Net::LDAP.new \
        base: Setting.value(:ldap, :basename),
        host: Setting.value(:ldap, :hostname),
        port: Setting.value(:ldap, :portnumber),
        encryption: :simple_tls
      unless Setting.value(:ldap, :bind_dn).nil?
        @@ldap.auth Setting.value(:ldap, :bind_dn), Setting.value(:ldap, :bind_password)
      end
    end

    def check_username(username)
      unless username =~ /^([a-zA-Z]|\d)+$/
        raise ActiveRecord::StatementInvalid.new('invalid username')
      end
    end
  end
end
