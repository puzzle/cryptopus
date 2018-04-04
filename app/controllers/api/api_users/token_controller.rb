require 'user/api'

class Api::ApiUsers::TokenController < ApplicationController

  # POST /api/api_users/token/1
  def update
    authorize api_user
    api_user.renew_token(session[:private_key])
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
