# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

module Authentication
  module Authenticators
    class UserPassword

      def initialize(params)
        @username = params[:username]
        @password = params[:password]
      end

      def params_present?
        username.present? && password.present?
      end

      def auth!
        user.authenticate(password)
      end

      def user
        @user ||= find_user
      end

      private

      attr_reader :username, :password

      def find_user
        # password required for initial ldap user creation
        User.find_or_import_from_ldap(username.strip, password)
      end

    end
  end
end
