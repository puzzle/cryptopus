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
    add_error t('flashes.admin.admin.no_access')
  end

  def pending_recrypt_request_message
    add_error('Wait for the recryption of your users team passwords')
    @response_status = 403
  end

  def authentification_failed_message
    add_error('Authentification failed')
    @response_status = 401
  end

  def user_not_logged_in_message
    add_error('User not logged in')
    @response_status = 401
  end
end
