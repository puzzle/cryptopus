# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'
describe Log do
  it 'cannot create log with unknown status' do
    log = Log.new(status: 'unknown', log_type: 'maintenance_task')
    expect(log).to_not be_valid
    expect(log.errors.messages[:status].first).to match(/not included/)
  end

  it 'cannot create log with unknown log_type' do
    log = Log.new(status: 'failed', log_type: 'unknown')
    expect(log).to_not be_valid
    expect(log.errors.messages[:log_type].first).to match(/not included/)
  end
end
