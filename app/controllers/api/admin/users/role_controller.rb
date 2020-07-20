# frozen_string_literal: true

class Api::Admin::Users::RoleController < ApiController

  def update
    role = params[:role]
    raise ArgumentError unless allowed?(role)

    user = User::Human.find(params[:id])
    authorize user, :update_role?
    user.update_role(current_user, role, session[:private_key])

    add_info(t("flashes.api.admin.users.update.#{role}"))
    render_json
  end

  private

  def allowed?(role)
    roles = [:user, :conf_admin]
    if current_user.admin?
      roles << :admin
    end
    roles.map(&:to_s).include?(role)
  end
end
