# frozen_string_literal: true

class Encryptables::LogPolicy < TeamDependantPolicy
  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    @user.is_a?(User::Human)
  end

  def show?
    team.teammember?(@user.id)
  end

  protected

  def team
    @record.folder.team
  end
end
