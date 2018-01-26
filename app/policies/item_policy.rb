class ItemPolicy < TeamDependantPolicy
  def show?
    team_member?(current_user, item.account.group.team)
  end

  def new?
    team_member?(current_user, item.account.group.team)
  end

  def create?
    team_member?(current_user, item.account.group.team)
  end

  def destroy?
    team_member?(current_user, item.account.group.team)
  end

  private

  def current_user
    @user
  end

  def item
    @record
  end
end
