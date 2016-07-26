class Api::Admin::UsersController < ApiController

  def toggle_admin
    user = User.find(params[:user_id])
    user.toggle_admin(current_user, session[:private_key])
    
    toggle_way = user.admin? ? 'empowered' : 'disempowered'
    add_info(t("flashes.api.admin.users.toggle.#{toggle_way}", username: user.username))
    render_json ''
  end
end
