# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'user/api'

class Authentication::ApiUserAuthenticator

  def initialize(headers)
    @authenticated = false
    @headers = headers
  end

  def auth!
    return false unless preconditions?
    return false if user_locked? || user.expired?

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
    @user ||= find_api_user
  end

  private

  attr_accessor :authenticated
  attr_reader :headers

  def brute_force_detector
    @brute_force_detector ||=
      Authentication::BruteForceDetector.new(user)
  end

  def preconditions?
    if headers_present? && user.present?
      return true
    end
    add_error('flashes.logins.wrong_password')
    false
  end

  def headers_present?
    api_username.present? && api_token.present?
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

  def find_api_user
    User::Api.find_by(username: api_username.strip)
  end

  def api_username
    # request.headers['HTTP_API_USER']
    headers['HTTP_API_USER']
  end

  def api_token
    # request.headers['HTTP_API_TOKEN']
    headers['HTTP_API_TOKEN']
  end

  def user_auth!
    user.authenticate(api_token)
  end

end
