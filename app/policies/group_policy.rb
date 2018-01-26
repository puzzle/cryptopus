class GroupPolicy < TeamDependantPolicy
  def show?
    team_member?(current_user, group.team)
  end

  def new?
    team_member?(current_user, group.team)
  end

  def create?
    team_member?(current_user, group.team)
  end

  def edit?
    team_member?(current_user, group.team)
  end

  def update?
    team_member?(current_user, group.team)
  end

  def destroy?
    team_member?(current_user, group.team)
  end

  private

  def current_user
    @user
  end

  def group
    @record
  end

  class Scope < TeamDependantScope
    def initialize(current_user, team)
      @current_user = current_user
      @team = team
    end

    def resolve
      if team_member?(@current_user, @team)
        @team.groups.all
      end
    end
  end
end
