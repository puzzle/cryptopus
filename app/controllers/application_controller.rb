# $Id$

# Copyright (c) 2007 Puzzle ITC GmbH. All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  before_filter :redirect_to_wizard_if_new_setup
  before_filter :authorize, except: [:login, :authenticate, :logout, :wizard]
  before_filter :prepare_menu
  before_filter :set_locale
  before_filter :set_cache_headers

  helper_method :current_user

  # includes a security token
  protect_from_forgery with: :null_session

  private

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
      redirect_to login_logout_path
    end
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

  def get_team_password(team)
    user = User.find(session[:user_id] )
    teammember = team.teammembers.where("user_id = ?", user.id).first
    raise "You have no access to this Group" if teammember.nil?
    team_password = CryptUtils.decrypt_team_password( teammember.password, session[:private_key] )
    raise "Failed to decrypt the group password" if team_password.nil?
    return team_password
  end

  def is_user_team_member( team_id, user_id )
    team_member = Teammember.where("team_id=? and user_id=?", team_id, user_id ).first
    return true if team_member
    return false
  end

  def prepare_menu
    if File.exist?("#{Rails.root}/app/views/#{controller_path}/_#{action_name}_menu.html.erb")
      @menu_to_render = "#{controller_path}/#{action_name}_menu"
    else
      @menu_to_render = nil
    end
  end

  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
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
