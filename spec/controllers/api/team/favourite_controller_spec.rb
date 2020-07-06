# frozen_string_literal: true

require 'rails_helper'

describe Api::Teams::FavouriteController do
  include ControllerHelpers

  let(:bob) { users(:bob) }

  context 'POST create' do
    it 'Adds new team to favourites' do
      login_as(:bob)
      team2 = teams(:team2)

      expect do
        post :create, params: { team_id: team2.id }, xhr: true
      end.to change { bob.favourite_teams.count }.by(1)
      expect(response).to have_http_status(201)
    end

    it 'does not create new favourite team without team memberhip' do
      login_as(:alice)
      team = teams(:team2)

      post :create, params: { team_id: team }, xhr: true

      expect(response).to have_http_status(403)
    end

    it 'keeps favourite when team is already a favourite' do
      login_as(:bob)

      expect do
        post :create, params: { team_id: teams(:team1) }, xhr: true
      end.to_not(change { UserFavouriteTeam.count })

      expect(response).to have_http_status(201)
    end
  end

  context 'DELETE destroy' do
    it 'removes favourite from user' do
      login_as(:alice)
      team = teams(:team1)

      expect do
        delete :destroy, params: { team_id: team }, xhr: true
      end.to change { UserFavouriteTeam.count }.from(4).to(3)
      expect(response).to have_http_status(204)
    end

    it 'returns ok if team was already removed' do
      login_as(:bob)
      expect do
        delete :destroy, params: { team_id: teams(:team2) }, xhr: true
      end.to_not(change { UserFavouriteTeam.count })
      expect(response).to have_http_status(204)
    end

    it 'doesn\'t remove favourite from user if not team member' do
      login_as(:alice)
      entry = double
      expect_any_instance_of(Api::Teams::FavouriteController).to receive(:fetch_entry)
        .exactly(:once)
        .and_return(entry)
      expect(entry).to receive(:policy_class).exactly(:once).and_return(UserFavouriteTeamPolicy)
      expect(entry).to receive(:team).exactly(:once).and_return(teams(:team2))

      delete :destroy, params: { team_id: teams(:team2) }, xhr: true
      expect(response).to have_http_status(403)
    end
  end
end
