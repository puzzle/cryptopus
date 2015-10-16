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
  before_filter :validate, :except => [:login, :authenticate, :logout]
  before_filter :prepare_menu
  before_filter :set_locale
  before_filter :set_cache_headers


  # includes a security token
  # protect_from_forgery with: :exception


protected

  def validate
    unless session[:user_id]
      session[:jumpto] = request.parameters
      redirect_to login_login_path
      return
    end

    user = User.find( session[:user_id] )
    if Recryptrequest.where("user_id = ?", user.id).first
      flash[:notice] = t('flashes.application.wait')
      redirect_to :controller => 'login', :action => 'logout'
      return
    end

  end

  def set_locale
    user_locale = session[:user_id] ? User.find( session[:user_id] ).preferred_locale : I18n.default_locale
    # use the locale parameter if provided or else the user locale
    I18n.locale = params[:locale] || user_locale
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

  def am_i_team_member( team_id )
    user = User.find( session[:user_id] )
    return is_user_team_member( team_id, user.id )
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
    redirect_to wizard_path if User.all.count <= 0
    flash[:notice] = t('flashes.logins.welcome')
  end
  #rescue_from ActionController::InvalidAuthenticityToken do |exception|
  #  logout
  #end

end
