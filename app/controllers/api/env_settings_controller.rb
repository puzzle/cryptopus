# frozen_string_literal: true

class Api::EnvSettingsController < ApiController
  include ApplicationHelper

  skip_before_action :validate_user
  before_action :skip_authorization

  def index
    render_json(sentry: ENV['SENTRY_DSN_FRONTEND'],
                current_user: { id: current_user.id,
                                role: current_user.role,
                                givenname: current_user.givenname,
                                preferred_locale: current_user.preferred_locale },
                last_login_message: last_login_message,
                version: version_number,
                csrf_token: form_authenticity_token)
  end

  private

  def last_login_message
    Flash::LastLoginMessage.new(session).message
  end

end
