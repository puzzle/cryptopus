require 'user/api'

class Api::ApiUsers::TokenController < ApiController

  # GET /api/api_users/token/1
  def show
    authorize api_user
    api_user.renew_token(session[:private_key])
    render_json api_user
  end

  # DELETE /api/api_users/token/1
  def destroy
    authorize api_user
    api_user.update!(locked: true)
  end

  private

  def api_user
    @api ||= User::Api.find(params[:id])
  end
end
