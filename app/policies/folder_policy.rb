# frozen_string_literal: true

class FolderPolicy < TeamDependantPolicy
  def index?
    true
  end

  def show?
    team_member?
  end

  private

  def team
    folder.team
  end

  def folder
    @record
  end
end
