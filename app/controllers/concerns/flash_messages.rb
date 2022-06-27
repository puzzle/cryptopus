# frozen_string_literal: true

module FlashMessages
  extend ActiveSupport::Concern

  def team_not_existing_message(id)
    flash[:error] = t('flashes.teams.not_existing', id: id)
  end

  def pending_recrypt_request_message
    flash[:notice] = t('flashes.application.wait')
  end
end
