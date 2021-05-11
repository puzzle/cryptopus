# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'spec_helper'
describe Admin::MaintenanceTasksHelper do
  include ApplicationHelper

  it 'creates label and input for password tag' do
    param = { label: :test, type: 'password' }
    result = create_maintenance_task_field(param)

    expect(result).to match(/<label/)
    expect(result).to match(/<input/)
    expect(result).to match(/type="password"/)
    expect(result).to match(/name="task_params\[test\]"/)
  end

  it 'creates label and input for number' do
    param = { label: :test, type: 'number' }
    result = create_maintenance_task_field(param)

    expect(result).to match(/type="number"/)
  end

  it 'creates label and input for text' do
    param = { label: :test, type: 'text' }
    result = create_maintenance_task_field(param)

    expect(result).to match(/type="text"/)
  end

  it 'creates text input if unknown type' do
    param = { label: :test, type: 'unknown' }
    result = create_maintenance_task_field(param)

    expect(result).to match(/type="text"/)
  end
end
