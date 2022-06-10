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
    require 'pry'; binding.pry unless $pstop
    @record.receiver_id.present? &&
      current_user.present? &&
      user_human? &&
      sender_himself?
  end

  def user_human?
    User.find(@record.receiver_id).type == User::Human
  end

  def sender_himself?
    @record.receiver_id != current_user.id
  end

end
