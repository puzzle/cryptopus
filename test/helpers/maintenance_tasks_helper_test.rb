# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class MaintenanceTasksHelperTest < ActionView::TestCase
  include ApplicationHelper
  include Admin::MaintenanceTasksHelper

  test 'create label and input for password tag' do
    param = {label: :test, type: "password"}
    result = create_maintenance_task_field(param)

    assert_match /<label/, result
    assert_match /<input/, result
    assert_match /type="password"/, result
    assert_match /name="task_params\[test\]"/, result
  end

  test 'create label and input for number' do
    param = {label: :test, type: "number"}
    result = create_maintenance_task_field(param)

    assert_match /type="number"/, result
  end

  test 'create label and input for text' do
    param = {label: :test, type: "text"}
    result = create_maintenance_task_field(param)

    assert_match /type="text"/, result
  end

  test 'creates text input if unknown type' do
  param = {label: :test, type: "unknown"}
    result = create_maintenance_task_field(param)

    assert_match /type="text"/, result
  end
end
