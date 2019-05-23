# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

module FlashMessages
  extend ActiveSupport::Concern

  included do
    before_action :message_if_fallback
    before_action :redirect_to_wizard_if_new_setup
  end

  def message_if_fallback
    flash[:error] = t('fallback') if ENV['CRYPTOPUS_FALLBACK'] == 'true'
  end

  def redirect_to_wizard_if_new_setup
    if User.all.count <= 0
      redirect_to wizard_path
      flash[:notice] = t('flashes.logins.welcome')
    end
  end

  def team_not_existing_message(id)
    flash[:error] = t('flashes.teams.not_existing', id: id)
  end

  def pending_recrypt_request_message
    flash[:notice] = t('flashes.application.wait')
  end
end
