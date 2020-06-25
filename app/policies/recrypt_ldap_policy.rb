# frozen_string_literal: true

class RecryptLdapPolicy < ApplicationPolicy
  def new?
    user.ldap?
  end

  def create?
    true
  end
end
