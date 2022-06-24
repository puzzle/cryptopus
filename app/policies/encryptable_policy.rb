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
    team.teammember?(@user.id) || transferring_encryptable?
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
    @record.receiver_id.present? &&
      receiver_personal_team_owner? &&
      user_human? &&
      @record.is_a?(Encryptable::File)
  end

  def user_human?
    User.find(@record.receiver_id).is_a?(User::Human)
  end

  def receiver_personal_team_owner?
    @record.folder.team.owner.id == @record.receiver_id
  end

end
