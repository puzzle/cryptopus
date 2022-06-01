# frozen_string_literal: true

class Api::UserCandidatesController < ApplicationController
  def index
    authorize team, :team_member?
    candidates = team.member_candidates
    render_json candidates
  end
end
