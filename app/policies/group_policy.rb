class GroupPolicy < TeamChildrenPolicy

  def initialize(current_user, group)
    @current_user = current_user
    @group = group
  end

  def show?
    team_member?(@current_user, @group.team)
  end

  def new?
    team_member?(@current_user, @group.team)
  end

  def create?
    team_member?(@current_user, @group.team)
  end

  def edit?
    team_member?(@current_user, @group.team)
  end

  def update?
    team_member?(@current_user, @group.team)
  end

  def destroy?
    team_member?(@current_user, @group.team)
  end

  class Scope < TeamChildrenScope
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
