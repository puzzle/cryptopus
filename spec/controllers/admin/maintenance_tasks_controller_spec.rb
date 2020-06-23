# frozen_string_literal: true

require 'rails_helper'

describe Admin::MaintenanceTasksController do
  include ControllerHelpers

  context 'GET index' do
    it 'cant access index by non-root' do
      login_as(:bob)

      get :index
      expect(response).to redirect_to(root_path)
    end

    it 'gets all maintenance tasks without ldap' do
      login_as(:admin)

      get :index

      maintenance_tasks = assigns(:maintenance_tasks)

      expect(maintenance_tasks.size).to eq 0
    end

    it 'gets all maintenance tasks with ldap enabled' do
      enable_ldap
      login_as(:admin)

      get :index
      maintenance_tasks = assigns(:maintenance_tasks)

      expect(maintenance_tasks.size).to eq 1
    end

    context 'POST execute' do

      it 'executes cannot be accessed by non-root' do
        enable_ldap
        login_as(:bob)

        post :execute, params: { id: 3 }
        expect(response).to redirect_to root_path
      end

      it 'executes task' do
        enable_ldap
        mock_ldap_settings
        expect_any_instance_of(LdapConnection).to receive(:test_connection).and_return(true)

        login_as(:admin)

        expect do
          post :execute, params: { id: 3 }
          expect(response).to render_template 'admin/maintenance_tasks' \
                                              '/removed_ldap_users/result.html.haml'
        end.to change { Log.count }.by(1)

        expect(flash[:notice]).to match(/successfully/)
      end

      it 'displays error if task execution fails' do
        enable_ldap

        login_as(:admin)

        expect do
          post :execute, params: { id: 3 }
          expect(response).to redirect_to admin_maintenance_tasks_path
        end.to change { Log.count }.by(1)

        expect(flash[:error]).to match(/Task failed/)
      end

      it 'returns 404 if invalid maintenance task id' do
        login_as(:admin)

        expect do
          post :execute, params: { id: 42, task_params: {} }
        end.to raise_error(ActionController::RoutingError)
      end

      it 'executes task and renders result page' do
        enable_ldap
        mock_ldap_settings
        login_as(:admin)

        expect_any_instance_of(LdapConnection).to receive(:test_connection).and_return(true)

        expect do
          post :execute, params: { id: 3 }
          expect(response).to render_template 'admin/maintenance_tasks' \
                                              '/removed_ldap_users/result.html.haml'
        end.to change { Log.count }.by(1)

        expect(flash[:notice]).to match(/successfully/)
      end
    end
  end
end
