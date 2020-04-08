# frozen_string_literal: true

require 'rails_helper'

module PolicyHelper
  protected

  def assert_permit(user, record, action)
    expect(Pundit.policy!(user, record).public_send(action)).to eq(true)
  end

  def refute_permit(user, record, action)
    expect(Pundit.policy!(user, record).public_send(action)).to eq(false)
  end

  def admin
    users(:admin)
  end

  def conf_admin
    users(:conf_admin)
  end

  def bob
    users(:bob)
  end

  def alice
    users(:alice)
  end

  def root
    users(:root)
  end

  def ldap_user
    ldap_user = users(:bob)
    ldap_user.auth = 'ldap'
    ldap_user
  end
end
