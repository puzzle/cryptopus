require 'test_helper'

class MaintenanceTaskPolicyTest < PolicyTest

  context '#index' do
    test 'admin sees maintenance tasks' do
      assert_not_nil MaintenanceTaskPolicy::Scope.new(admin, MaintenanceTask).resolve
    end

    test 'non-admin cant see maintenance tasks' do
      assert_nil MaintenanceTaskPolicy::Scope.new(bob, MaintenanceTask).resolve
    end
  end

  context '#execute' do
    test 'admin can execute maintenance tasks' do
      assert_permit admin, MaintenanceTask, :execute?
    end

    test 'non-admin cant execute maintenance tasks' do
      refute_permit bob, MaintenanceTask, :execute?      
    end
  end
end
