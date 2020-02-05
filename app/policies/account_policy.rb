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

  def update?
    team.teammember?(@user.id)
  end

  def permitted_attributes
    %i[accountname group_id description cleartext_username cleartext_password tag]
  end

  def create_item?
    team_member?
  end

  def move?
    team_member?
  end

  protected

  def team
    @record.group.team
  end
end
