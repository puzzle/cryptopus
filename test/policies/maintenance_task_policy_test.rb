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

  context '#execute' do
      test 'admin can execute enabled maintenance tasks' do
        enable_ldap
        assert_permit admin, task, :execute?
      end

      test 'admin cannot execute disabled maintenance tasks' do
        MaintenanceTasks::RemovedLdapUsers.any_instance
                                         .expects(:enabled?)
                                         .returns(false)

        refute_permit admin, task, :execute?
      end

      test 'conf_admin can execute enabled maintenance tasks' do
        enable_ldap
        assert_permit conf_admin, task, :execute?
      end

      test 'conf_admin cannot execute disabled maintenance tasks' do
        MaintenanceTasks::RemovedLdapUsers.any_instance
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
      MaintenanceTasks::RemovedLdapUsers.new
    end

end
