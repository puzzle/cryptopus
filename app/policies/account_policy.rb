class AccountPolicy < TeamChildrenPolicy

  def initialize(current_user, account)
    @current_user = current_user
    @account = account
  end

  def show?
    team_member?(@current_user, @account.group.team)
  end

  def new?
    team_member?(@current_user, @account.group.team)
  end

  def create?
    team_member?(@current_user, @account.group.team)
  end

  def edit?
    team_member?(@current_user, @account.group.team)
  end

  def update?
    team_member?(@current_user, @account.group.team)
  end

  def destroy?
    team_member?(@current_user, @account.group.team)
  end

  def move?
    team_member?(@current_user, @account.group.team)
  end

  class Scope < TeamChildrenScope
    def initialize(current_user, group)
      @current_user = current_user
      @group = group
    end

    def resolve
      if team_member?(@current_user, @group.team)
        @group.accounts.all
      end
    end
  end
end
