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
    return true if transferring_encryptable?

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
    @record.team
  end

  private

  def transferring_encryptable?
    @record.transferred?
  end

end
