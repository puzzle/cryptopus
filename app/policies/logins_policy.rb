class LoginsPolicy < ApplicationPolicy

  def login?
    user.nil?
  end

  def authenticate?
    user.nil?
  end

  def logout?
    user.present?
  end

  def show_update_password?
    user.present? && !user.ldap?
  end

  def update_password?
    user.present? && !user.ldap?
  end

  def changelocale?
    user.present?
  end

end
