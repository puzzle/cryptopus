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
    team.teammember?(@user.id)
  end

  protected

  def team
    @record.folder.team
  end
end
