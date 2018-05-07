class GroupPolicy < TeamDependantPolicy
  def index?
    true
  end

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
end
