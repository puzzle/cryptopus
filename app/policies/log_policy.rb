# frozen_string_literal: true

class LogPolicy < TeamDependantPolicy
  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    @user.is_a?(User::Human) && team.teammember?(@user.id)
  end

  def show?
    team.teammember?(@user.id)
  end

  protected

  def team
    @record
  end
end
