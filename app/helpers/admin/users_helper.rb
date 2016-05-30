# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
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

  def link_to_destroy_soloteams_and_user
    user = User.find_by id: flash[:user_to_delete]
    path = destroy_with_soloteams_admin_user_path(user.id)
    confirm = t('confirm.deleteWithTeams', username: user.username)

    link_to 'Delete teams',
            path, class: "btn btn-primary pull-right", id: "soloteams_cancel_button" ,
            data: { confirm: confirm},
            method: :delete
  end

end
