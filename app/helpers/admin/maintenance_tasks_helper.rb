# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

module Admin::MaintenanceTasksHelper
  def create_maintenance_task_field(param)
    label = param[:label]
    content = ''
    content << label_tag(label)

    content << create_tag_with_correct_type(label, param[:type])
    content_tag(:div, content.html_safe, class: 'form-group').html_safe
  end

  def create_tag_with_correct_type(label, type)
      method_name = "#{type}_field_tag"
      method_exists = !try(method_name, '').nil?
      if method_exists
        send(method_name, "task_params[#{label}]", '', default_field_options)
      else
        create_tag_with_correct_type(label, 'text')
      end
  end
end
