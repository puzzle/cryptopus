# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'
describe Admin::SettingsHelper do
  include ApplicationHelper

  it 'creates label and input for text' do
    setting = Setting.find_by(key: 'general_ip_whitelist')
    result = input_field_setting(setting)
    expect(result)
      .to match(/This would be the range between <kbd>192.0.2.0<\/kbd> and <kbd>192.0.2.255<\/kbd>/)
    expect(result).to match(/<input/)
    expect(result).to match(/name="setting\[general_ip_whitelist\]\[\]"/)
    expect(result).to match(/value="#{setting.value[0]}"/)
  end
end
