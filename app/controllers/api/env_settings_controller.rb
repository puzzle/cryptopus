# frozen_string_literal: true

class Api::EnvSettingsController < ApiController
  include ApplicationHelper

  skip_before_action :validate_user
  before_action :skip_authorization

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def index
    base_url = ENV['RAILS_HOST_NAME'] ? "https://#{ENV['RAILS_HOST_NAME']}" : request.base_url
    render_json(sentry: ENV['SENTRY_DSN_FRONTEND'],
                current_user: { id: current_user.id,
                                role: current_user.role,
                                givenname: current_user.givenname,
                                last_login_at: current_user.last_login_at,
                                last_login_from: current_user.last_login_from,
                                preferred_locale: current_user.preferred_locale },
                last_login_message: last_login_message,
                version: version_number,
                csrf_token: form_authenticity_token,
                base_url: base_url)
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  private

  def last_login_message
    Flash::LastLoginMessage.new(session).message
  end

end
