module Authentication
  module Authenticators
    class ::UserPassword

      def initialize(params)
        @username = params[:username]
        @password = params[:password]
      end

      def params_present?
        @username.present? && @password.present?
      end

      def auth!
        user.authenticate(@username, @password)
      end

      def user
        @user ||= find_user
      end

      private
      # def two_factor_required?
      # end
      def find_user
        # password required for initial ldap user creation
        User.find_or_import_from_ldap(@username, @password)
      end

    end
  end
end
