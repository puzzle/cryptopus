# encoding: utf-8

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

      def initialize(user)
        @user = user
      end

      def render
        content_tag(:div, class: 'btn-group', id: @user.id) do
          safe_join([render_button, render_menu])
        end
      end

      private

      def render_button
        content_tag(:span, class: 'btn btn-default dropdown-toggle', id: 'role-dropdown', 'data-toggle': 'dropdown') do
          safe_join([role_label(@user.role), content_tag(:b, '', class: 'caret')])
        end
      end

      def render_menu
        content_tag(:ul, class: 'dropdown-menu', 'aria-labelledby': 'dropdownMenuButton') do
          safe_join(items)
        end
      end

      def items
        roles.collect do |role|
          render_item(role)
        end
      end

      def render_item(role)
        content_tag(:li, class: 'dropdown-item', val: role) do
          role_label(role)
        end
      end

      def roles
        roles = ROLES
        roles += ADMIN if @user.admin?
        roles
      end

      def role_label(role)
        t('admin.user_roles.' + role)
      end
    end
  end
end
