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
    team.teammember?(@user.id) && !non_api_user_accesses_openshift_secret?
  end

  def update?
    team.teammember?(@user.id) && !non_api_user_accesses_openshift_secret?
  end

  protected

  def team
    @record.folder.team
  end

  private

  def non_api_user_accesses_openshift_secret?
    @user.type != 'User::Api' && @record.openshift_secret?
  end
end
