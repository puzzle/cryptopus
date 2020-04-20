# frozen_string_literal: true

# == Schema Information
#
# Table name: groups
#
#  id          :integer          not null, primary key
#  name        :string(40)       default(""), not null
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  team_id     :integer          default(0), not null
#

require 'rails_helper'

describe GroupsController do
  include ControllerHelpers

  context 'GET show' do
    render_views

    it 'shows breadcrumb path 1 if user is on index of groups' do
      login_as(:bob)
      group1 = groups(:group1)
      team1 = teams(:team1)

      get :show, params: { id: group1, team_id: team1 }

      expect(response.body).to match(/href="\/accounts\/#{accounts(:account1).id}"/)
      expect(response.body).to match(/Teams/)
      expect(response.body).to match(/team1/)
    end

    it 'doesnt show breadcrumb path 1 if conf_admin is on index of groups' do
      login_as(:tux)
      group1 = groups(:group1)
      team1 = teams(:team1)

      get :show, params: { id: group1, team_id: team1 }

      expect(response.body).not_to match(/href="\/accounts\/#{accounts(:account1).id}"/)
      expect(response.body).not_to match(/Teams/)
      expect(response.body).not_to match(/team1/)
    end

    it 'shows breadcrumb path 1 if admin is on index of groups' do
      login_as(:admin)
      group1 = groups(:group1)
      team1 = teams(:team1)

      get :show, params: { id: group1, team_id: team1 }

      expect(response.body).to match(/href="\/accounts\/#{accounts(:account1).id}"/)
      expect(response.body).to match(/Teams/)
      expect(response.body).to match(/team1/)
    end

    it 'redirects if not teammember' do
      team2 = teams(:team2)
      group2 = groups(:group2)

      login_as(:alice)

      get :show, params: { id: group2, team_id: team2 }

      expect(flash[:error]).to match(/Access denied/)
      expect(response).to redirect_to teams_path
    end

    it 'redirects admin if not teammember' do
      team2 = teams(:team2)
      group2 = groups(:group2)

      login_as(:admin)

      get :show, params: { id: group2, team_id: team2 }

      expect(flash[:error]).to match(/Access denied/)
      expect(response).to redirect_to teams_path
    end

    it 'redirects conf_admin if not teammember' do
      team2 = teams(:team2)
      group2 = groups(:group2)

      login_as(:tux)

      get :show, params: { id: group2, team_id: team2 }

      expect(flash[:error]).to match(/Access denied/)
      expect(response).to redirect_to teams_path
    end
  end

  context 'GET edit' do
    render_views

    it 'shows breadcrumb path 2 if user is on edit of groups' do
      login_as(:bob)
      team1 = teams(:team1)
      group1 = groups(:group1)

      get :edit, params: { id: group1, team_id: team1 }

      expect(response.body).to match(/Teams/)
      expect(response.body).to match(/team1/)
      expect(response.body).to match(/group1/)
    end

    it 'shows breadcrumb path 2 if admin is on edit of groups' do
      login_as(:admin)
      team1 = teams(:team1)
      group1 = groups(:group1)

      get :edit, params: { id: group1, team_id: team1 }

      expect(response.body).to match(/Teams/)
      expect(response.body).to match(/team1/)
      expect(response.body).to match(/group1/)
    end

    it 'conf_admin is redirected on edit of groups' do
      login_as(:tux)
      team1 = teams(:team1)
      group1 = groups(:group1)

      get :edit, params: { id: group1, team_id: team1 }

      assert_redirected_to teams_path
    end
  end

  context 'PUT update' do
    it 'updates group name and description' do
      login_as(:alice)
      group = groups(:group1)
      team = teams(:team1)

      update_params = { name: 'new_name', description: 'new_description' }
      put :update, params: { team_id: team, id: group, group: update_params }

      group.reload

      expect(group.name).to eq 'new_name'
      expect(group.description).to eq 'new_description'
    end

    it 'updates group name and description as admin' do
      login_as(:admin)
      group = groups(:group1)
      team = teams(:team1)

      update_params = { name: 'new_name', description: 'new_description' }
      put :update, params: { team_id: team, id: group, group: update_params }

      group.reload

      expect(group.name).to eq 'new_name'
      expect(group.description).to eq 'new_description'
    end

    it 'conf_admin cannot update group name and description' do
      login_as(:tux)
      group = groups(:group1)
      team = teams(:team1)

      update_params = { name: 'new_name', description: 'new_description' }
      put :update, params: { team_id: team, id: group, group: update_params }

      group.reload

      expect(group.name).not_to eq 'new_name'
      expect(group.description).not_to eq 'new_description'
    end
  end

  context 'DELETE destroy' do
    it 'deletes group as teammember' do
      login_as(:bob)
      team1 = teams(:team1)
      group1 = groups(:group1)

      expect do
        delete :destroy, params: { id: group1, team_id: team1 }
      end.to change { Group.count }.by(-1)

      expect(response).to redirect_to team_path(team1)
    end

    it 'deletes group as admin' do
      login_as(:admin)
      team1 = teams(:team1)
      group1 = groups(:group1)

      expect do
        delete :destroy, params: { id: group1, team_id: team1 }
      end.to change { Group.count }.by(-1)

      expect(response).to redirect_to team_path(team1)
    end

    it 'doesnt delete group as conf_admin' do
      login_as(:tux)
      team1 = teams(:team1)
      group1 = groups(:group1)

      delete :destroy, params: { id: group1, team_id: team1 }

      assert_redirected_to teams_path
    end
  end
end
