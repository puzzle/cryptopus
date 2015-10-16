class WizardController < ApplicationController
  before_filter :first_setup
  skip_before_filter :validate

  def index
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def apply
    password = params[:password]
    password_repeat = params[:password_repeat]

    if !password.empty? && !password_repeat.empty?
      if password == password_repeat
        User.create_root password
        create_root_session password
        return
      else
        flash[:error] = t('flashes.wizard.paswords_do_not_match')
      end
    else
      flash[:error] = t('flashes.wizard.fill_password_fields')
    end
    redirect_to wizard_path
  end

  private

  def create_root_session(password)
    user = User.find_by_username('root')
    request.session[:user_id] = user.id
    session[:private_key] = CryptUtils.decrypt_private_key( user.private_key, password )
    redirect_to admin_users_path
  end

  def first_setup
    redirect_to login_login_path if User.all.count > 0
  end
end