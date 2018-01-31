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

  context '#prepare' do
    test 'admin can prepare enabled maintenance tasks' do
      assert_permit admin, task, :prepare?
    end
    
    test 'admin cannot prepare disabled maintenance tasks' do
      MaintenanceTasks::NewRootPassword.any_instance
                                       .expects(:enabled?)
                                       .returns(false)
      
      refute_permit admin, task, :prepare?
    end

    test 'non-admin cannot prepare enabled maintenance tasks' do
      refute_permit bob, task, :prepare?      
    end
  end

  context '#execute' do
    test 'admin can execute enabled maintenance tasks' do
      assert_permit admin, task, :execute?
    end
    
    test 'admin cannot execute disabled maintenance tasks' do
      MaintenanceTasks::NewRootPassword.any_instance
                                       .expects(:enabled?)
                                       .returns(false)
      
      refute_permit admin, task, :execute?
    end

    test 'non-admin cannot execute enabled maintenance tasks' do
      refute_permit bob, task, :execute?      
    end
  end

  private

  def task
    MaintenanceTasks::NewRootPassword.new
  end

end
