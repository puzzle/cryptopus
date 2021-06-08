# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

module ApiMessages
  extend ActiveSupport::Concern

  def add_error(msg)
    messages[:errors] << msg
  end

  def add_info(msg)
    messages[:info] << msg
  end

  private

  def messages
    @messages ||=
      { errors: [], info: [] }
  end

  def response_status
    @response_status || success_or_error
  end

  def success_or_error
    messages[:errors].present? ? :internal_server_error : nil
  end

  def no_access_message
    @response_status = :forbidden
    add_error('flashes.admin.admin.no_access')
  end

  def authentification_failed_message
    @response_status = :unauthorized
    add_error('flashes.api.errors.auth_failed')
  end

  def user_not_logged_in_message
    @response_status = :unauthorized
    add_error('flashes.api.errors.user_not_logged_in')
  end

  def bad_request_message
    @response_status = :bad_request
    add_error('flashes.api.errors.bad_request')
  end

  def not_found_message
    @response_status = :not_found
    add_error('flashes.api.errors.record_not_found')
  end
end
