class ItemPolicy < TeamDependantPolicy
  def show?
    team_member?
  end

  def new?
    team_member?
  end

  def destroy?
    team_member?
  end

  protected

  def team
    item.account.group.team
  end

  private

  def current_user
    @user
  end

  def item
    @record
  end
end
