# frozen_string_literal: true

require 'spec_helper'
describe UserFavouriteTeam do

  let(:user) { users(:bob) }

  context 'new' do
    it 'does not add second user in same team' do
      params = {
        user_id: users(:alice).id,
        team_id: teams(:team1).id
      }
      user_favourite_team = UserFavouriteTeam.new(params)
      expect(user_favourite_team).to_not be_valid
    end

    it 'can add second user' do
      params1 = {
        user_id: users(:admin).id,
        team_id: teams(:team2).id
      }
      params2 = {
        user_id: users(:alice).id,
        team_id: teams(:team2).id
      }

      user_favourite_team1 = UserFavouriteTeam.new(params1)
      user_favourite_team2 = UserFavouriteTeam.new(params2)
      expect(user_favourite_team1).to be_valid
      expect(user_favourite_team2).to be_valid
    end
  end
end
