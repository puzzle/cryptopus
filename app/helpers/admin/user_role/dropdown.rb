#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

module Admin
  module UserRole
    class Dropdown

      include ActionView::Helpers::OutputSafetyHelper
      include ActionView::Helpers::TagHelper
      include ActionView::Context

      ROLES = %w[user conf_admin].freeze
      ADMIN = %w[admin].freeze

      delegate :t, to: I18n

      def initialize(user, current_user)
        @user = user
        @current_user = current_user
      end

      def render
        content_tag(:div, class: 'dropdown', id: @user.id) do
          content = [render_button]
          content += [render_menu] if button_enabled?
          safe_join(content)
        end
      end

      private

      def render_button
        content_tag(:button, class: button_style, id: 'role-dropdown', 'data-toggle': 'dropdown') do
          content = [content_tag(:span, role_label(@user.role))]
          content += [content_tag(:span, '', class: 'caret')] if button_enabled?
          safe_join(content)
        end
      end

      def render_menu
        content_tag(:ul, class: 'dropdown-menu', 'aria-labelledby': 'role-dropdown') do
          safe_join(items)
        end
      end

      def button_style
        style = %w[btn btn-default dropdown-toggle]
        style << 'disabled' unless button_enabled?
        style.join(' ')
      end

      def items
        roles.collect do |role|
          render_item(role)
        end
      end

      def render_item(role)
        content_tag(:li, id: 'dropdown-role', class: 'dropdown-item', val: role) do
          role_option(role)
        end
      end

      def roles
        roles = ROLES
        roles += ADMIN if @current_user.admin?
        roles
      end

      def own_user?
        @user == @current_user
      end

      def button_enabled?
        return false if own_user?
        if @user.admin? && !@current_user.admin?
          false
        else
          true
        end
      end

      def role_option(role)
        content_tag(:a, href: '#') do
          role_label(role)
        end
      end

      def role_label(role)
        t('admin.user_roles.' + role)
      end
    end
  end
end
