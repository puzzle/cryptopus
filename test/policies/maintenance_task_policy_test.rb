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

  context '#prepare' do
    test 'admin can prepare enabled maintenance tasks' do
      assert_permit admin, task, :prepare?
    end
  
    test 'conf_admin can prepare enabled maintenance tasks' do
      assert_permit conf_admin, task, :prepare?
    end   
 
    test 'admin cannot prepare disabled maintenance tasks' do
      MaintenanceTasks::RootAsAdmin.any_instance
                                       .expects(:enabled?)
                                       .returns(false)
      
      refute_permit admin, task, :prepare?
    end

    test 'conf_admin cannot prepare disabled maintenance tasks' do
      MaintenanceTasks::RootAsAdmin.any_instance
                                       .expects(:enabled?)
                                       .returns(false)
      cadmin = conf_admin
      refute_permit cadmin, task, :prepare?
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
      MaintenanceTasks::RootAsAdmin.any_instance
                                       .expects(:enabled?)
                                       .returns(false)
      
      refute_permit admin, task, :execute?
    end

    test 'conf_admin can execute enabled maintenance tasks' do
      assert_permit conf_admin, task, :execute?
    end
    
    test 'conf_admin cannot execute disabled maintenance tasks' do
      MaintenanceTasks::RootAsAdmin.any_instance
                                       .expects(:enabled?)
                                       .returns(false)
      
      refute_permit conf_admin, task, :execute?
    end

    test 'non-admin cannot execute enabled maintenance tasks' do
      refute_permit bob, task, :execute?      
    end
  end

  private

  def task
    MaintenanceTasks::RootAsAdmin.new
  end

end
