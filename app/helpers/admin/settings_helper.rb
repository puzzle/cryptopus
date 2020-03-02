# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

module Admin::SettingsHelper
  def input_field_setting(setting)
    return selectize_input_field(setting) if selectize_input_field(setting)

    content = ''
    content += label_tag(setting.key)

    content += if respond_to?(input_field_formatter(setting))
                 send(input_field_formatter(setting), setting)
               else
                 input_field_setting_default(setting)
               end
    # rubocop:disable Rails/OutputSafety
    safe_join([content_tag(:div, content.html_safe, class: 'form-group')])
    # rubocop:enable Rails/OutputSafety
  end

  def selectize_input_field(setting)
    if setting.key == 'general_country_source_whitelist'
      render 'admin/settings/country_source_whitelist'
    elsif setting.key == 'general_ip_whitelist'
      render 'admin/settings/ip_whitelist'
    end
  end

  def input_field_setting_default(setting)
    text_field_tag(key_param(setting), setting.value, default_field_options)
  end

  private

  def input_field_formatter(setting)
    str = ''
    str += 'input_field_setting_'
    str += setting.class.name.demodulize.underscore
    str.to_sym
  end

  def key_param(setting)
    "setting[#{setting.key}]"
  end

end
