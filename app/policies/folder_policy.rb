# frozen_string_literal: true

class FolderPolicy < TeamDependantPolicy
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

  def update?
    !personal_team? && super
  end

  def destroy?
    !personal_team? && super
  end

  private

  def personal_team?
    folder.team.id == @user.personal_team.id
  end

  def team
    folder.team
  end

  def folder
    @record
  end
end
