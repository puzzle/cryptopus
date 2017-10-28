# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.


class Authentication::UserPasswordAuthenticator

  def initialize(params)
    @authenticated = false
    @params = params
  end

  def auth!
    return false unless preconditions?
    return false if user_locked?

    authenticated = user_auth!

    unless authenticated
      add_error('flashes.logins.wrong_password')
    end

    brute_force_detector.update(authenticated)
    authenticated
  end

  def errors
    @errors ||= []
  end

  def user
    @user ||= find_user
  end

  private

  attr_accessor :authenticated
  attr_reader :params

  def brute_force_detector
    @brute_force_detector ||=
      Authentication::BruteForceDetector.new(user)
  end

  def preconditions?
    if params_present? && valid_username? && user.present?
      return true
    end
    add_error('flashes.logins.wrong_password')
    false
  end

  def params_present?
    username.present? && password.present?
  end

  def valid_username?
    username.strip =~ /^([a-zA-Z]|\d)+$/
  end

  def user_locked?
    unless brute_force_detector.locked?
      return false
    end
    add_error('flashes.logins.locked')
    true
  end

  def add_error(msg_key)
    errors << I18n.t(msg_key)
  end

  def find_user
    # password required for initial ldap user creation
    User.find_or_import_from_ldap(username.strip, password)
  end

  def username
    params[:username]
  end

  def password
    params[:password]
  end

  def user_auth!
    user.authenticate(password)
  end

end
