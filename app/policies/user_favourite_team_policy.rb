# frozen_string_literal: true

class UserFavouriteTeamPolicy < TeamDependantPolicy
  def create?
    favourite.user == current_user && team_member?
  end

  def destroy?
    team_member?
  end

  private

  def current_user
    @user
  end

  def team
    @record.team
  end

  def favourite
    @record
  end
end
