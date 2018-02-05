class Api::Admin::Users::RoleController < Api::Admin::AdminController
 
  def update
    user = User.find(params[:id])
    authorize user
    role = params[:role]
    return add_error(t('flashes.api.admin.users.no_access')) if update_role_not_allowed(role)
    user.update_role(current_user, role, session[:private_key])

    add_info(t("flashes.api.admin.users.update.#{role}", username: user.username))
    render_json ''
  end
  
  private 

  def update_role_not_allowed(role)
    current_user.conf_admin? && role == 'admin'
  end
end
