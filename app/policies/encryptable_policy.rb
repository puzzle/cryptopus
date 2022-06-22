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
    return true if encryptable_transfer

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

  def encryptable_transfer
  @record.transfered? &&
      user.present? &&
      @record.is_a?(Encryptable::File)
  end

end
