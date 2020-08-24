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

  private

  def team
    folder.team
  end

  def folder
    @record
  end
end
