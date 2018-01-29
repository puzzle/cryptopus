class GroupPolicy < TeamDependantPolicy
  def show?
    team_member?
  end

  def new?
    team_member?
  end

  def create?
    team_member?
  end

  def edit?
    team_member?
  end

  def update?
    team_member?
  end

  def destroy?
    team_member?
  end

  protected

  def team
    group.team
  end

  private

  def current_user
    @user
  end

  def group
    @record
  end

  class Scope < TeamDependantScope
    def resolve
      if team_member?
        team.groups.all
      end
    end

    protected

    def team
      @scope
    end

  end
end
