class GroupPolicy < TeamDependantPolicy
  private

  def team
    group.team
  end

  def current_user
    @user
  end

  def group
    @record
  end

  class Scope < TeamDependantScope
    def resolve
      if team_member?
        team.groups
      end
    end

    def resolve_all
      @user.groups
    end

    protected

    def team
      @scope
    end

  end
end
