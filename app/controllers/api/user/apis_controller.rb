require 'user/api'

class Api::User::ApisController < ApiController

  # GET /api/api_users
  def index
    authorize User::Api
    @apis = current_user.api_users
    render_json @apis
  end

  # GET /api/api_users/1
  def show
    authorize api
    render_json api
  end

  # POST /api/api_users
  def create
    new_api = current_user.api_users.new(permitted_attributes(User::Api))
    authorize new_api
    new_api.save!
    add_info(t('flashes.api.api-users.create', username: new_api.username))
    render_json new_api
  end

  # POST /api/api_users/1
  def update
    authorize api
    params = permitted_attributes(api)
    api.update!(params)
    flash_update_info(api, params)
    render_json api
  end

  # DELETE /api/api_users/1
  def destroy
    authorize api
    api.destroy!
    add_info(t('flashes.api.api-users.destroy', username: api.username))
    render_json ''
  end

  # GET /api/api_users/1/lock
  def lock
    authorize api
    api.lock
    add_info(t('flashes.api.api-users.lock', username: api.username))
    render_json ''
  end

  # GET /api/api_users/1/unlock
  def unlock
    authorize api
    api.unlock
    add_info(t('flashes.api.api-users.unlock', username: api.username))
    render_json ''
  end

  private

  def api
    @api ||= User::Api.find(params[:id])
  end

  def flash_update_info(api, params)
    username = api.username
    if params['description'].present?
      add_info(t('flashes.api.api-users.update.description', username: username))
    elsif params['valid_for']
      add_info(t('flashes.api.api-users.update.valid_for', username: username, valid_for: valid_for(params)))
    end
  end

  def valid_for(param)
    time = param['valid_for'].to_i
    unless(time == 0)
      time = time.seconds
    end
    time_s = User::Api::VALID_FOR_OPTIONS.invert[time].to_s
    t('flashes.api.api-users.update.time.' + time_s)
  end
end
