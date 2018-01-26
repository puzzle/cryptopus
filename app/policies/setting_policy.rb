class SettingPolicy < ApplicationPolicy

  def initialize(current_user, setting)
    @current_user = current_user
    @setting = setting
  end

  def index?
    @current_user.admin? || @current_user.conf_admin?
  end

  def update_all?
    @current_user.admin? || @current_user.conf_admin?
  end
end
