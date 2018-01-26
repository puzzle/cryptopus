class SettingPolicy < ApplicationPolicy
  def index?
    admin_or_conf_admin?
  end

  def update_all?
    admin_or_conf_admin?
  end

  private

  def current_user
    @user
  end

  def setting
    @record
  end
end
