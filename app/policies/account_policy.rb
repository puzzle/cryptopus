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

  def create_item?
    team_member?
  end

  protected

  def team
    @record.group.team
  end
end
