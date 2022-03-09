# frozen_string_literal: true

class FileEntryPolicy < TeamDependantPolicy
  def index?
    true
  end

  def show
    team_member?
  end

  def create
    team_member?
  end

  def destroy
    team_member?
  end

  private

  def team
    file_entry.encryptable.folder.team
  end

  def file_entry
    @record
  end
end
