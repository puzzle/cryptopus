# frozen_string_literal: true

class LogPolicy < TeamPolicy
  def index?
    team_member?
  end

  def show?
    @team.teammember?(@user.id) && !@user.is_a?(User::Api)
  end
end
