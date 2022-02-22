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
    if @record.is_a?(Encryptable::File)
      @record.encryptable_credential.folder.team
    else
      @record.folder.team
    end
  end
end
