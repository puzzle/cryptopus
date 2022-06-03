# frozen_string_literal: true

class Api::UserCandidatesController < ApiController
  def index
    if team_id_present?
      authorize team, :team_member?
      candidates = team.member_candidates
      render_json candidates
    else
      authorize :user_candidates, :index?
      candidates = sharing_candidates
      render_json candidates
    end
  end

  private

  def team_id_present?
    params[:team_id].present?
  end

  def sharing_candidates
    User::Human.where.not(id: current_user.id)
  end

end
