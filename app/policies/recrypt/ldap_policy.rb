# frozen_string_literal: true

class Recrypt::LdapPolicy < ApplicationPolicy
  def new?
    user.ldap? && AuthConfig.ldap_enabled?
  end

  def create?
    user.ldap? && AuthConfig.ldap_enabled?
  end
end
