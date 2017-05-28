# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

module Authentication
  class IpWhitelist
    require 'ipaddr'

    PRIVATE_IP_RANGES = ['10.0.0.0/8', '127.0.0.0/8',
                         '172.16.0.0/12', '192.168.0.0/16',
                         '::1'].freeze

    def list
      private_ip_ranges + whitelist_by_setting
    end

    private

    def whitelist_by_setting
      Setting.value('general', 'ip_whitelist').collect do |i|
        IPAddr.new(i)
      end
    end

    def private_ip_ranges
      PRIVATE_IP_RANGES.collect do |r|
        IPAddr.new(r)
      end
    end

  end
end
