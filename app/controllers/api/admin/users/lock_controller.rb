# frozen_string_literal: true

class Api::Admin::Users::LockController < ApiController
  def destroy
    authorize user, :unlock?

    user.unlock!
    add_info(t('flashes.api.api-users.unlock', username: user.username))

    render_json
  end

  private

  def user
    @user ||= User::Human.find(params[:id])
  end
end
