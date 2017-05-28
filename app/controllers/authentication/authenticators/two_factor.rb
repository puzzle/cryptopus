# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

module Authentication
  module Authenticators
    class TwoFactor < UserPassword

      class << self
        def two_factor_required?(remote_ip)
          return false unless two_factor_enabled?
          ip = IPAddr.new(remote_ip)
          whitelisted_ips.none? {|i| i.include?(ip) }
        end

        def whitelisted_ips
          Authentication::IpWhitelist.new.list
        end

        def two_factor_enabled?
          Setting.value('general', 'two_factor_auth')
        end
      end

      def initialize(params)
        @two_factor_token = params[:two_factor_token]
        super
      end

      def params_present?
        two_factor_token.present && super
      end

      def auth!
        super && two_factor_auth!
      end

      private

      attr_reader :two_factor_token
      
      def two_factor_auth!
      end

    end
  end
end
