class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    # api users have only access to show and find accounts, all other actions are forbidden
    raise Pundit::NotAuthorizedError if user.is_a?(User::Api)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    scope.where(id: record.id).exists?
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def admin_or_conf_admin?
    @user.admin? || @user.conf_admin?
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end

    def admin_or_conf_admin?
      @user.admin? || @user.conf_admin?
    end
  end
end
