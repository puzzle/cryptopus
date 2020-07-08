# frozen_string_literal: true

module Api
  module Teams
    class FavouriteController < ApiController
      self.custom_model_class = UserFavouriteTeam

      private

      def build_entry
        entry
      end

      def fetch_entry
        current_user.user_favourite_teams.find_or_initialize_by(team: team)
      end

      def render_entry(_options = {})
        head 201
      end
    end
  end
end
