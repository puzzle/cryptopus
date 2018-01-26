class TeamPolicy < TeamDependantPolicy
  def initialize(current_user, team)
    @current_user = current_user
    @team = team
  end

  def create?
    true
  end

  def update?
    (@current_user.admin? && !@team.private?) || team_member?(@current_user, @team)
  end

  def destroy?
    @current_user.admin? || (@current_user.conf_admin? && @team.members.size == 1)
  end

  def last_teammember_teams?
    @current_user.admin?
  end

  def add_member?
    team_member?(@current_user, @team)
  end

  def remove_member?
    team_member?(@current_user, @team)
  end

  class Scope < TeamDependantScope
    def initialize(current_user, team)
      @current_user = current_user
      @team = team
    end

    def resolve
      @current_user.teams
    end

    def resolve_members
      @team.teammembers.list if team_member?(@current_user, @team)
    end
  end
end
