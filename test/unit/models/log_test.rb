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