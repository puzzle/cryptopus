# frozen_string_literal: true

class SettingPolicy < ApplicationPolicy
  def index?
    admin_or_conf_admin?
  end

  def update_all?
    admin_or_conf_admin?
  end

  def ldap_connection_test?
    admin_or_conf_admin?
  end
end
