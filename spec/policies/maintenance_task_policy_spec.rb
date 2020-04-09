# frozen_string_literal: true

require 'rails_helper'

describe MaintenanceTaskPolicy do
  include PolicyHelper

  let(:task) { MaintenanceTasks::RemovedLdapUsers.new }

  context 'as admin' do
    context '#index' do
      it 'sees maintenance tasks' do
        assert_permit admin, MaintenanceTask, :index?
      end
    end

    context '#execute' do
      it 'can execute enabled maintenance tasks' do
        enable_ldap
        assert_permit admin, task, :execute?
      end

      it 'cannot execute disabled maintenance tasks' do
        expect_any_instance_of(MaintenanceTasks::RemovedLdapUsers)
          .to receive(:enabled?)
          .and_return(false)
        refute_permit admin, task, :execute?
      end
    end
  end

  context 'as conf_admin' do
    context '#index' do
      it 'sees maintenance tasks' do
        assert_permit conf_admin, MaintenanceTask, :index?
      end
    end
    context '#execute' do
      it 'can execute enabled maintenance tasks' do
        enable_ldap
        assert_permit conf_admin, task, :execute?
      end

      it 'conf_admin cannot execute disabled maintenance tasks' do
        expect_any_instance_of(MaintenanceTasks::RemovedLdapUsers)
          .to receive(:enabled?)
          .and_return(false)

        refute_permit conf_admin, task, :execute?
      end
    end
  end

  context 'non-admin' do
    context '#index' do
      it 'cannot see maintenance tasks' do
        refute_permit bob, MaintenanceTask, :index?
      end
    end

    context '#execute' do
      it 'cannot execute enabled maintenance tasks' do
        refute_permit bob, task, :execute?
      end
    end
  end
end
