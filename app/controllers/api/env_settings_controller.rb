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
                                username: current_user.username,
                                last_login_at: current_user.last_login_at,
                                last_login_from: current_user.last_login_from,
                                preferred_locale: current_user.preferred_locale,
                                default_ccli_user_id: current_user.default_ccli_user_id,
                                auth: current_user.auth },
                last_login_message: last_login_message,
                geo_ip: GeoIp.activated?,
                version: version_number,
                csrf_token: form_authenticity_token,
                auth_provider: AuthConfig.provider,
                base_url: base_url)
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  private

  def last_login_message
    Flash::LastLoginMessage.new(session).message
  end

end
