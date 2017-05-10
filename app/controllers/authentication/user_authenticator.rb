# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.


class Authentication::UserAuthenticator

  def initialize(params)
    @authenticated = false
    @params = params
  end

  def password_auth!
    return false unless preconditions?
    return false if user_locked?

    unless authenticated = authenticator.auth!
      add_error('flashes.logins.wrong_password')
    end

    brute_force_detector.update(authenticated)
    authenticated
  end

  def api_key_auth!
    raise 'not yet implemented'
  end

  def errors
    @errors ||= []
  end

  def user
    authenticator.user
  end

  private

  attr_accessor :authenticated, :params

  def authenticator
    @authenticator ||=
      Authentication::Authenticators::UserPassword.new(params)
  end

  def brute_force_detector
    @brute_force_detector ||=
      Authentication::BruteForceDetector.new(user)
  end

  def preconditions?
    if params_present? && user.present?
      return true
    end
    add_error('flashes.logins.wrong_password')
    false
  end

  def params_present?
    authenticator.params_present?
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

end
