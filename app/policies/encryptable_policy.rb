# frozen_string_literal: true

class EncryptablePolicy < TeamDependantPolicy
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
    team.teammember?(@user.id)
  end

  def update?
    team.teammember?(@user.id)
  end

  def destroy?
    team_member?
  end

  protected

  def team
    @record.folder.team
  end
end
