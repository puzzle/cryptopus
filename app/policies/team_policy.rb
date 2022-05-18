# frozen_string_literal: true

class TeamPolicy < TeamDependantPolicy
  def initialize(user, record)
    @user = user
    @record = record
  end

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
    return false if personal_team?

    (current_user.admin? && !team.private?) || team_member?
  end

  def destroy?
    return false if personal_team?

    current_user.is_a?(User::Human) &&
      (current_user.admin? || (current_user.conf_admin? && team.members.size == 1))
  end

  def only_teammember?
    admin_or_conf_admin?
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

  def personal_team?
    @record.personal_team?
  end
end
