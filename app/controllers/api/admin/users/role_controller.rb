class Api::Admin::Users::RoleController < Api::Admin::AdminController

  def update
    role = params[:role]
    raise ArgumentError unless allowed?(role)

    user = User::Human.find(params[:id])
    skip_authorization
    authorize user, :update_role?
    user.update_role(current_user, role, session[:private_key])

    add_info(t("flashes.api.admin.users.update.#{role}", username: user.username))
    render_json ''
  end

  private

  def allowed?(role)
    roles = %i[user conf_admin]
    if current_user.admin?
      roles << :admin
    end
    roles.map(&:to_s).include?(role)
  end
end
