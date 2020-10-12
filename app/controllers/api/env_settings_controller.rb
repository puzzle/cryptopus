# frozen_string_literal: true

class Api::EnvSettingsController < ApiController
  include ApplicationHelper

  skip_before_action :validate_user
  before_action :skip_authorization

  def index
    base_url = ENV['RAILS_HOST_NAME'] ? "https://#{ENV['RAILS_HOST_NAME']}" : request.base_url
    render_json(sentry: ENV['SENTRY_DSN_FRONTEND'],
                current_user: { id: current_user.id,
                                role: current_user.role,
                                givenname: current_user.givenname,
                                preferred_locale: current_user.preferred_locale },
                last_login_message: last_login_message,
                version: version_number,
                csrf_token: form_authenticity_token,
                base_url: base_url)
  end

  private

  def last_login_message
    Flash::LastLoginMessage.new(session).message
  end

end
