class TeamChildrenPolicy < ApplicationPolicy
  def team_member?(user, team)
    team.teammember?(user.id)
  end

  class TeamChildrenScope < Scope
    def team_member?(user, team)
      team.teammember?(user.id)
    end
  end
end
