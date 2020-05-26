# frozen_string_literal: true

# == Schema Information
#
# Table name: folders
#
#  id          :integer          not null, primary key
#  name        :string(40)       default(""), not null
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  team_id     :integer          default(0), not null
#

require 'rails_helper'

describe FoldersController do
  include ControllerHelpers

  context 'GET show' do
    render_views

    it 'shows breadcrumb path 1 if user is on index of folders' do
      login_as(:bob)
      folder1 = folders(:folder1)
      team1 = teams(:team1)

      get :show, params: { id: folder1, team_id: team1 }

      expect(response.body).to match(/href="\/accounts\/#{accounts(:account1).id}"/)
      expect(response.body).to match(/Teams/)
      expect(response.body).to match(/team1/)
    end

    it 'redirects if not teammember' do
      team2 = teams(:team2)
      folder2 = folders(:folder2)

      login_as(:alice)

      get :show, params: { id: folder2, team_id: team2 }

      expect(flash[:error]).to match(/Access denied/)
      expect(response).to redirect_to teams_path
    end
  end

  context 'GET edit' do
    render_views

    it 'shows breadcrumb path 2 if user is on edit of folders' do
      login_as(:bob)
      team1 = teams(:team1)
      folder1 = folders(:folder1)

      get :edit, params: { id: folder1, team_id: team1 }

      expect(response.body).to match(/Teams/)
      expect(response.body).to match(/team1/)
      expect(response.body).to match(/folder1/)
    end
  end

  context 'PUT update' do
    it 'updates folder name and description' do
      login_as(:alice)
      folder = folders(:folder1)
      team = teams(:team1)

      update_params = { name: 'new_name', description: 'new_description' }
      put :update, params: {team_id: team, id: folder, folder: update_params }

      folder.reload

      expect(folder.name).to eq 'new_name'
      expect(folder.description).to eq 'new_description'
    end
  end

  context 'DELETE destroy' do
    it 'deletes folder as teammember' do
      login_as(:bob)
      team1 = teams(:team1)
      folder1 = folders(:folder1)

      expect do
        delete :destroy, params: { id: folder1, team_id: team1 }
      end.to change { Folder.count }.by(-1)

      expect(response).to redirect_to team_path(team1)
    end
  end
end
