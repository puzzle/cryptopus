# frozen_string_literal: true

require 'user/api'

class Api::ApiUsersController < ApiController
  self.permitted_attrs = [:description, :valid_for]
  self.custom_model_class = ::User::Api

  private

  def build_entry
    @user_api = current_user.api_users.new(model_params)
  end

  def fetch_entries
    if current_user.is_a?(User::Human)
      current_user.api_users
    else
      current_user.human_user.api_users
    end
  end

  def valid_for(param)
    time = param['valid_for'].to_i
    unless time.zero?
      time = time.seconds
    end
    time_s = User::Api::VALID_FOR_OPTIONS.invert[time].to_s
    t("flashes.api.api-users.update.time.#{time_s}")
  end
end
