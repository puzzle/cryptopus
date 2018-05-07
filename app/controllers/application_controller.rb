# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.
#
require 'user' # fixes user.authenticate problem

class ApplicationController < ActionController::Base

  before_action :validate_user, except: %i[login authenticate logout wizard]
  before_action :message_if_fallback
  before_action :redirect_if_no_private_key, except: :logout
  before_action :prepare_menu
  before_action :set_locale

  include PolicyCheck
  include SourceIpCheck
  include UserSession
  include Caching
  include FlashMessages

  # includes a security token
  protect_from_forgery with: :exception

  private

  # redirect if its not possible to decrypt user's private key
  def redirect_if_no_private_key
    if current_user.is_a?(User::Human) && !active_session?
      redirect_to recryptrequests_new_ldap_password_path
    end
  end

  def validate_user
    handle_pending_recrypt_request
    check_if_user_logged_in
  end

  def handle_pending_recrypt_request
    if pending_recrypt_request?
      pending_recrypt_request_message
      redirect_to logout_login_path
    end
  end

  def check_if_user_logged_in
    if current_user.nil?
      session[:jumpto] = request.parameters
      redirect_to login_login_path
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

  def prepare_menu
    if File.exist?(Rails.root.join('app',
                                   'views',
                                   '#{controller_path}', '_#{action_name}_menu.html.haml'))
      @menu_to_render = "#{controller_path}/#{action_name}_menu"
    else
      @menu_to_render = nil
    end
  end

  def default_url_options(options = {})
    { locale: I18n.locale }.merge options
  end

  def team
    @team ||= Team.find(params[:team_id])
  end

  def active_session?
    session[:private_key].present?
  end

  def team_id
    params[:team_id]
  end
end
