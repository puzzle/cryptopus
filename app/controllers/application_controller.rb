# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class ApplicationController < ActionController::Base
  before_filter :redirect_to_wizard_if_new_setup
  before_filter :authorize, except: [:login, :authenticate, :logout, :wizard]
  before_filter :redirect_if_not_teammember
  before_filter :redirect_if_no_private_key, except: :logout
  before_filter :prepare_menu
  before_filter :set_locale
  before_filter :set_cache_headers

  helper_method :current_user

  # includes a security token
  protect_from_forgery with: :null_session

  private

  #redirect if its not possible to decrypt user's private key
  def redirect_if_no_private_key
    if current_user && session[:private_key].nil?
      redirect_to recryptrequests_new_ldap_password_path
    end
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def authorize
    if current_user.nil?
      session[:jumpto] = request.parameters
      redirect_to login_login_path
    else
      redirect_if_pending_recryptrequest
    end
  end

  def redirect_if_pending_recryptrequest
    if current_user.recryptrequests.first
      flash[:notice] = t('flashes.application.wait')
      redirect_to logout_login_path
    end
  end

  def redirect_if_not_teammember
    team_id = params[:team_id]
    return if team_id.nil?
    team = Team.find(team_id)
    return if team.teammember?(current_user.id)
    flash[:error] = t('flashes.teams.no_member')
    redirect_to teams_path
  end

  def plaintext_team_password(team)
    raise 'You have no access to this team' unless team.teammember?(current_user.id)
    private_key = session[:private_key]
    plaintext_team_password = team.decrypt_team_password(current_user, private_key)
    raise 'Failed to decrypt the team password' unless plaintext_team_password
    plaintext_team_password
  end

  def set_locale
    locale = I18n.default_locale
    if current_user
      locale = current_user.preferred_locale
    elsif params[:locale]
      locale = params[:locale]
    end
    I18n.locale = locale
  end

  def prepare_menu
    if File.exist?("#{Rails.root}/app/views/#{controller_path}/_#{action_name}_menu.html.haml")
      @menu_to_render = "#{controller_path}/#{action_name}_menu"
    else
      @menu_to_render = nil
    end
  end

  def set_cache_headers
    response.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = 'Fri, 01 Jan 1990 00:00:00 GMT'
  end

  def redirect_to_wizard_if_new_setup
    if User.all.count <= 0
      redirect_to wizard_path
      flash[:notice] = t('flashes.logins.welcome')
    end
  end

  def default_url_options(options = {})
    { locale: I18n.locale }.merge options
  end
end
