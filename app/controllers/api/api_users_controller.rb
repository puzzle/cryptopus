# frozen_string_literal: true

require 'user/api'

class Api::ApiUsersController < ApiController

  # GET /api/api_users
  def index
    authorize User::Api
    api_users = current_user.api_users
    render_json api_users
  end

  # GET /api/api_users/1
  def show
    authorize api_user
    render_json api_user
  end

  # POST /api/api_users
  def create
    new_api_user = current_user.api_users.new(permitted_attributes(User::Api))
    authorize new_api_user
    new_api_user.save!
    add_info(t('flashes.api.api-users.create', username: new_api_user.username))
    render_json new_api_user
  end

  # POST /api/api_users/1
  def update
    authorize api_user
    params = permitted_attributes(api_user)
    api_user.update!(params)
    flash_update_info(api_user, params)
    render_json api_user
  end

  # DELETE /api/api_users/1
  def destroy
    authorize api_user
    api_user.destroy!
    add_info(t('flashes.api.api-users.destroy', username: api_user.username))
    render_json ''
  end

  private

  def api_user
    @api_user ||= User::Api.find(params[:id])
  end

  def flash_update_info(api, params)
    username = api.username
    if params['description'].present?
      add_info(t('flashes.api.api-users.update.description', username: username))
    end
    if params['valid_for'].present?
      add_info(t('flashes.api.api-users.update.valid_for',
                 username: username, valid_for: valid_for(params)))
    end
  end

  def valid_for(param)
    time = param['valid_for'].to_i
    unless time.zero?
      time = time.seconds
    end
    time_s = User::Api::VALID_FOR_OPTIONS.invert[time].to_s
    t('flashes.api.api-users.update.time.' + time_s)
  end
end
