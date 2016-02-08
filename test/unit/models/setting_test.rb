# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class SettingTest <  ActiveSupport::TestCase
  test 'returns boolean' do
    setting = Setting::TrueFalse.create(key: 'bla', value: 'f')
    setting.value = true
    assert setting.value.is_a?(TrueClass)
  end
end