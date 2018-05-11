# encoding: utf-8

# == Schema Information

# Table name: users
#
#  id                           :integer          not null, primary key
#  public_key                   :text             not null
#  private_key                  :binary           not null
#  password                     :binary
#  ldap_uid                     :integer
#  last_login_at                :datetime
#  username                     :string
#  givenname                    :string
#  surname                      :string
#  auth                         :string           default("db"), not null
#  preferred_locale             :string           default("en"), not null
#  locked                       :boolean          default(FALSE)
#  last_failed_login_attempt_at :datetime
#  failed_login_attempts        :integer          default(0), not null
#  last_login_from              :string
#  type                         :string
#  human_user_id                :integer
#  options                      :text
#  role                         :integer          default("user"), not null
#

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

class User::ApiSerializer < ApplicationSerializer
  delegate :l, to: I18n

  attributes :id,
             :username,
             :description,
             :valid_until,
             :valid_for,
             :last_login_at,
             :last_login_from,
             :locked

  def valid_until
    valid_until = object.valid_until
    l(valid_until, format: '%Y-%m-%d::%H:%M') if valid_until
  end

  def last_login_at
    object.formatted_last_login_at
  end
end
