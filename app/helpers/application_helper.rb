# $Id$

# Copyright (c) 2007 Puzzle ITC GmbH. All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def tooltip(content, options = {}, html_options = {}, *parameters_for_method_reference)
    html_options[:title] = options[:tooltip]
    html_options[:class] = html_options[:class] || 'tooltip'
    content_tag("span", content, html_options)
  end

  def render_menu
    unless @menu_to_render.nil?
      render(:partial => @menu_to_render)
    end
  end

  def get_back_to_list_button(target_controller=nil, target_action="index")
    unless target_controller.nil?
      link_to(image_tag("previous.png") + " Back", :controller => target_controller, :action => target_action)
    else
      link_to(image_tag("previous.png") + " Back", :action => target_action)
    end
  end

  def nav_link(name, path)
    class_name = current_page?(path) ? 'active' : ''

    content_tag(:li, class: class_name) do
      link_to(name, path)
    end
  end

  def link_to_destroy(path, entry)
    entry_label = entry.label
    entry_class = entry.class.name.downcase
    label_key = "#{entry_class.pluralize}.confirm.delete"

    confirm = t(label_key, entry_class: entry_class, entry_label: entry_label, default: t("confirm.delete"))
    link_to image_tag("remove.png"),
            path, data:{confirm: confirm},
            method: :delete
  end

  def labeled_check_box(f, attr, enabled = true)
    options = {}
    options[:disabled] = 'disabled' unless enabled
    label_tag(attr) do
      concat f.check_box(attr, options)
      concat t(".#{attr.to_s}")
    end
  end

  private
  def default_field_options
    {class: 'form-control'}
  end

end
