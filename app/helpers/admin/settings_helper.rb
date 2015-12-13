module Admin::SettingsHelper
  def input_field_setting(setting)
    content = ''
    content << label_tag(setting.key)

    if respond_to?(input_field_formatter(setting))
      content << send(input_field_formatter(setting), setting)
    else
      content << input_field_setting_default(setting)
    end
    content_tag(:div, content.html_safe, class: 'form-group').html_safe
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
