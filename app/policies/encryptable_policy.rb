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
    return true if encryptable_transfer

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
    @record.receiver_id.present? &&
      user.present? &&
      user_human?
  end

  def user_human?
    User.find(@record.receiver_id).type == User::Human
  end

end
