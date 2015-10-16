class WizardController < ApplicationController
  before_filter :redirect_if_already_set_up
  skip_before_filter :validate, :redirect_to_wizard_if_new_setup

  def index
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def apply
    password = params[:password]
    password_repeat = params[:password_repeat]
    if !password.blank?
      if password == password_repeat
        User.create_root password
        create_session_and_redirect(password)
        return
      else
        flash[:error] = t('flashes.wizard.paswords_do_not_match')
      end
    else
      flash[:error] = t('flashes.wizard.fill_password_fields')
    end
    render 'index'
  end

  private

  def create_session_and_redirect(password)
    reset_session
    user = User.find_by_username('root')
    request.session[:user_id] = user.id
    request.session[:username] = user.username
    session[:private_key] = CryptUtils.decrypt_private_key( user.private_key, password )
    redirect_to admin_users_path
  end

  def redirect_if_already_set_up
    redirect_to login_login_path if User.all.count > 0
  end
end