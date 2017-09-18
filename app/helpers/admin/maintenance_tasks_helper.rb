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
    safe_join([content_tag(:div, content.html_safe, class: 'form-group')])
  end

  def create_tag_with_correct_type(label, type)
    return create_checkbox(label) if type == 'check_box'

    method_name = "#{type}_field_tag"

    method_exists = !try(method_name, '').nil?
    if method_exists
      send(method_name, "task_params[#{label}]", '', default_field_options.merge(required: true))
    else
      create_tag_with_correct_type(label, 'text')
    end
  end

  def create_checkbox(label, checked = false)
    method_name = 'check_box_tag'
    send(method_name, "task_params[#{label}]", '', checked, default_field_options)
  end
end
