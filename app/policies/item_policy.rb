class ItemPolicy < TeamDependantPolicy
  private

  def team
    item.account.group.team
  end

  def current_user
    @user
  end

  def item
    @record
  end
end
