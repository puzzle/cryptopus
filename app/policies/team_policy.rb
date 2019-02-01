class TeamPolicy < TeamDependantPolicy
  def index?
    true
  end

  def create?
    true
  end

  def new?
    true
  end

  def update?
    (current_user.admin? && !team.private?) || team_member?
  end

  def destroy?
    current_user.admin? || (current_user.conf_admin? && team.members.size == 1)
  end

  def last_teammember_teams?
    admin_or_conf_admin?
  end

  def add_member?
    team_member?
  end

  def remove_member?
    team_member?
  end

  def index_all?
    admin_or_conf_admin?
  end

  def list_members?
    team_member? || admin_or_conf_admin?
  end

  private

  def current_user
    @user
  end

  def team
    @record
  end
end
