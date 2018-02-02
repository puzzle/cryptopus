# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

module Admin::UsersHelper
  # Not finished

  def change_admin_attribute(user)
    class_name = 'toggle-button'
    class_name += ' toggle-button-selected' if user.admin?

    content_tag(:div, class: class_name, id: user.id) do
      content_tag(:button)
    end
  end

  def role(userrole)
    roles = ['User', 'Conf Admin', 'Admin']
    roles[User.roles[userrole]]
  end
end
