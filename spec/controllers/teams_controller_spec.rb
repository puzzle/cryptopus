# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  id          :integer          not null, primary key
#  name        :string(40)       default(""), not null
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  visible     :boolean          default(TRUE), not null
#  private     :boolean          default(FALSE), not null
#

require 'rails_helper'

describe TeamsController do
  include ControllerHelpers

  context 'GET index' do
    render_views

    it 'shows no delete button for teams to bob' do
      login_as(:bob)
      get :index
      expect(response.body).to_not match(/<a .* href="\/en\/teams\/#{teams(:team1).id}"/)
    end

    it 'shows delete button for teams to admin' do
      login_as(:admin)
      get :index
      expect(response.body).to match(/<a .* href="\/teams\/#{teams(:team1).id}"/)
    end

    it 'should redirect if pending recryptrequest' do
      Recryptrequest.create(user_id: users(:bob).id).save

      login_as(:bob)

      get :index

      expect(response).to redirect_to session_new_path
      expect(flash[:notice]).to match(/recryption of your team passwords/)
    end

    it 'redirects to login path if user has pending recryptrequests' do
      Recryptrequest.create(user_id: users(:bob).id)
      login_as(:bob)
      get :index
      expect(flash[:notice]).to match(/Wait for the recryption/)
    end
  end

  context 'GET edit' do
    render_views

    it 'shows breadcrump path 2 if user is on edit of team' do
      login_as(:bob)

      team1 = teams(:team1)

      get :edit, params: { id: team1 }

      expect(response.body).to match(/Teams/)
      expect(response.body).to match(/team1/)
    end
  end

  context 'POST create' do
    it 'creates new team as user' do
      login_as(:bob)

      team_params = { name: 'foo', private: false, description: 'foo foo' }

      expect do
        post :create, params: { team: team_params }
      end.to change { Team.count }.by(1)

      expect(response).to redirect_to teams_path

      team = Team.find_by(name: 'foo')
      expect(team.teammembers.count).to eq 3
      user_ids = team.teammembers.pluck(:user_id)
      expect(user_ids).to include(users(:bob).id, users(:admin).id)
      expect(team).to_not be_private
      expect(team.description).to eq 'foo foo'
    end
  end

  context 'PUT update' do
    it 'cannot enable private on existing team' do
      login_as(:alice)
      team = teams(:team1)

      expect(team).to_not be_private

      update_params = { private: true }

      put :update, params: { id: team, team: update_params }

      team.reload

      expect(team).to_not be_private
    end

    it 'cannot disable private on existing team' do
      login_as(:alice)

      team_params = { name: 'foo', private: true }
      team = Team.create(users(:alice), team_params)

      update_params = { private: false }

      put :update, params: { id: team, team: update_params }

      team.reload


      expect(team).to be_private
    end
  end

  context 'DELETE destroy' do
    it 'can delete team as admin if in team' do
      login_as(:admin)

      expect do
        delete :destroy, params: { id: teams(:team1).id }
      end.to change { Team.count }.by(-1)

      expect(response).to redirect_to teams_path
      expect(flash[:notice]).to match(/deleted/)
    end

    it 'cannot delete team as normal teammember' do
      login_as(:bob)

      expect do
        delete :destroy, params: { id: teams(:team1).id }
      end.to change { Team.count }.by(0)

      expect(response).to redirect_to teams_path
      expect(flash[:error]).to match(/Only admin/)
    end

    it 'cannot delete team as normal user if not in team' do
      login_as(:bob)

      teammembers(:team1_bob).delete

      expect do
        delete :destroy, params: { id: teams(:team1).id }
      end.to change { Team.count }.by(0)

      expect(response).to redirect_to teams_path
      expect(flash[:error]).to match(/Only admin/)
    end

    it 'can delete team as admin if not in team' do
      login_as(:admin)

      teammembers(:team1_admin).delete

      expect do
        delete :destroy, params: { id: teams(:team1).id }
      end.to change { Team.count }.by(-1)

      expect(response).to redirect_to teams_path
      expect(flash[:notice]).to match(/deleted/)
    end
  end
end
