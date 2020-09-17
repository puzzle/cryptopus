# frozen_string_literal: true

class AccountPolicy < TeamDependantPolicy
  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    true
  end

  def show?
    team.teammember?(@user.id)
  end

  def create?
    team.teammember?(@user.id) && !human_user_accesses_openshift_secret?
  end

  def update?
    team.teammember?(@user.id) && !human_user_accesses_openshift_secret?
  end

  def destroy?
    team_member? && !human_user_accesses_openshift_secret?
  end

  protected

  def team
    @record.folder.team
  end

  private

  def human_user_accesses_openshift_secret?
    @user.human? && @record.openshift_secret?
  end
end
