class Api::TeamsController < ApiController

  def teammember_candidates
    candidates = team.teammember_candidates
    render_json candidates
  end

  private
  def team
    @team ||= Team.find(params[:id])
  end

end
