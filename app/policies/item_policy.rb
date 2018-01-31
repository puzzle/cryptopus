class ItemPolicy < TeamDependantPolicy

  def initialize(current_user, item)
    @current_user = current_user
    @item = item
  end

  def show?
    team_member?(@current_user, @item.account.group.team)
  end

  def new?
    team_member?(@current_user, @item.account.group.team)
  end

  def create?
    team_member?(@current_user, @item.account.group.team)
  end

  def destroy?
    team_member?(@current_user, @item.account.group.team)
  end
end
