require 'test_helper'

class MaintenanceTaskPolicyTest < PolicyTest

  context '#index' do
    test 'admin sees maintenance tasks' do
      assert_permit admin, MaintenanceTask, :index?
    end

    test 'conf admin sees maintenance tasks' do
      assert_permit conf_admin, MaintenanceTask, :index?
    end

    test 'non-admin cannot see maintenance tasks' do
      refute_permit bob, MaintenanceTask, :index?
    end
  end

end
