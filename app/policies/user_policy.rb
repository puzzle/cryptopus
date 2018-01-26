class UserPolicy < ApplicationPolicy

  def initialize(current_user, user)
    @current_user = current_user
    @user = user
  end

  def index?
    @current_user.admin? || @current_user.conf_admin?
  end

  def update?
    if @user.non_admin?
      return @current_user.admin? || @current_user.conf_admin?
    end
    @current_user.admin?
  end

  def new?
    @current_user.admin? || @current_user.conf_admin?
  end

  def create?
    @current_user.admin? || @current_user.conf_admin?
  end

  def unlock?
    @current_user.admin? || @current_user.conf_admin?
  end

  def update_role?
    if @user.non_admin?
      return @current_user.admin? || @current_user.conf_admin?
    end
    @current_user.admin?
  end

  def destroy?
    # if @user.ldap_user?
    #   unless ldap_connection.exists?(@user.username)
    #     return @current_user.admin? || @current_user.conf_admin?
    #   end
    # else
    if @user.non_admin?
      return @current_user.admin? || @current_user.conf_admin?
    end
    # end
    @current_user.admin?
  end

  def resetpassword?
    unless @user.ldap_user?
      if @user.non_admin?
        return @current_user.admin? || @current_user.conf_admin?
      end
      @current_user.admin?
    end
  end

  def permitted_attributes_for_update
    return if @user.ldap_user?

    attrs = %i[givenname surname]

    if @current_user.admin?
      attrs + %i[username password]
    elsif @current_user.conf_admin?
      attrs
    end
  end

  def permitted_attributes_for_create
    %i[username givenname surname password] if @current_user.admin?
  end

  private

  def ldap_connection
    LdapConnection.new
  end

  class Scope < Scope
    def resolve
      if @user.admin? || @user.conf_admin?
        @scope.where('ldap_uid != 0 or ldap_uid is null')
      end
    end
  end
end
