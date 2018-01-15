# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.
#
require 'user' # fixes user.authenticate problem

class ApplicationController < ActionController::Base
  before_action :check_source_ip
  before_action :redirect_to_wizard_if_new_setup
  before_action :message_if_fallback
  before_action :validate_user, except: %i[login authenticate logout wizard]
  before_action :redirect_if_not_teammember
  before_action :redirect_if_no_private_key, except: :logout
  before_action :prepare_menu
  before_action :set_locale
  before_action :set_cache_headers

  helper_method :current_user

  # includes pundit, a scaleable authorization system
  include Pundit

  # verifies that authorize has been called in every action except index
  # after_action :verify_authorized, except: :index

  # verifies that policy_scope is used in index
  # after_action :verify_policy_scoped, only: :index

  # includes a security token
  protect_from_forgery with: :exception

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def check_source_ip
    return if ip_checker.previously_authorized?(session[:authorized_ip])

    if ip_checker.ip_authorized?
      session[:authorized_ip] = request.remote_ip
    else
      render layout: false, file: 'public/401.html', status: 401
    end
  end

  def ip_checker
    Authentication::SourceIpChecker.new(request.remote_ip)
  end

  # redirect if its not possible to decrypt user's private key
  def redirect_if_no_private_key
    if current_user && session[:private_key].nil?
      redirect_to recryptrequests_new_ldap_password_path
    end
  end

  def message_if_fallback
    flash[:error] = t('fallback') if ENV['CRYPTOPUS_FALLBACK'] == 'true'
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def validate_user
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
    if File.exist?(Rails.root.join('app',
                                   'views',
                                   '#{controller_path}', '_#{action_name}_menu.html.haml'))
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

  def team
    @team ||= Team.find(params[:team_id])
  end

  def user_not_authorized
    flash[:error] = t('flashes.admin.admin.no_access')
    redirect_to teams_path
    # redirect_to(request.referrer || root_path)
  end
end
