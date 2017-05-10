# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

module Admin::SettingsHelper
  def input_field_setting(setting)
    return selectize_input_field(setting) if selectize_input_field(setting)
    content = ''
    content << label_tag(setting.key)

    content << if respond_to?(input_field_formatter(setting))
                 send(input_field_formatter(setting), setting)
               else
                 input_field_setting_default(setting)
               end
    content_tag(:div, content.html_safe, class: 'form-group').html_safe
  end

  def selectize_input_field(setting)
    if setting.key == 'general_country_source_whitelist'
      return render 'admin/settings/country_source_whitelist'
    elsif setting.key == 'general_ip_whitelist'
      return render 'admin/settings/ip_whitelist'
    end
  end

  def input_field_setting_true_false(setting)
    content = hidden_field_tag(key_param(setting), 'f')
    content << check_box_tag(key_param(setting), 't', setting.value, default_field_options)
  end

  def input_field_setting_number(setting)
    number_field_tag(key_param(setting), setting.value, default_field_options)
  end

  def input_field_setting_default(setting)
    text_field_tag(key_param(setting), setting.value, default_field_options)
  end

  private

  def format_key(key)
    key.gsub(/^[a-z]+_{1}/, '')
  end

  def input_field_formatter(setting)
    str = ''
    str << 'input_field_setting_'
    str << setting.class.name.demodulize.underscore
    str.to_sym
  end

  def key_param(setting)
    "setting[#{setting.key}]"
  end
end
