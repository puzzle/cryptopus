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
      @user.groups
    end

    protected

    def team
      @scope
    end

  end
end
