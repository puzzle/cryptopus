class TeamDependantPolicy < ApplicationPolicy
  def team_member?(user, team)
    team.teammember?(user.id)
  end

  class TeamDependantScope < Scope
    def team_member?(user, team)
      team.teammember?(user.id)
    end
  end
end
