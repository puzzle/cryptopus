class TeamDependantPolicy < ApplicationPolicy
  def team_member?
    team.teammember?(@user.id)
  end

  protected

  def team
    raise 'missing method'
  end

  class TeamDependantScope < Scope
    def team_member?
      team.teammember?(@user.id)
    end

    protected

    def team
      raise 'missing method'
    end
  end
end
