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
