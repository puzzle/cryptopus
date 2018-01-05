# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class LogTest < ActiveSupport::TestCase
  test 'cannot create log with unknown status' do
    log = Log.new(status: 'unknown', log_type: 'maintenance_task')
    assert_not log.valid?
    assert_match /not included/, log.errors.messages[:status].first
  end

  test 'cannot create log with unknown log_type' do
    log = Log.new(status: 'failed', log_type: 'unknown')
    assert_not log.valid?
    assert_match /not included/, log.errors.messages[:log_type].first
  end
end