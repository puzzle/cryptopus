# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.
#

class ApplicationController < ActionController::Base
  before_action :set_sentry_request_context
  before_action :validate_user, except: [:new, :create, :destroy, :wizard]
  before_action :message_if_fallback
  before_action :redirect_if_no_private_key, except: [:destroy, :new]
  before_action :prepare_menu
  before_action :set_locale

  include PolicyCheck
  include SourceIpCheck
  include UserSession
  include Caching
  include FlashMessages

  protect_from_forgery with: :exception

  class_attribute :permitted_attrs

  delegate :model_identifier, to: :class

  # redirect if its not possible to decrypt user's private key
  def redirect_if_no_private_key
    if current_user.is_a?(User::Human) && !active_session?
      redirect_to recryptrequests_new_ldap_password_path
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
                                   controller_path.to_s, "_#{action_name}_menu.html.haml"))
      @menu_to_render = "#{controller_path}/#{action_name}_menu"
    else
      @menu_to_render = nil
    end
  end

  def set_sentry_request_context
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

  private

  def handle_pending_recrypt_request
    if pending_recrypt_request?
      pending_recrypt_request_message
      redirect_to sessions_path
    end
  end

  def check_if_user_logged_in
    if current_user.nil?
      session[:jumpto] = request.parameters
      redirect_to new_sessions_path
    end
  end

  def validate_user
    handle_pending_recrypt_request
    check_if_user_logged_in
  end

  def model_params
    params.require(model_identifier).permit(permitted_attrs)
  end

  def active_session?
    session[:private_key].present?
  end

  def team
    @team ||= Team.find(params[:team_id])
  end

  def team_id
    params[:team_id]
  end

  class << self
    def model_identifier
      @model_identifier ||= model_class.model_name.param_key
    end

    # The ActiveRecord class of the model.
    def model_class
      @model_class ||= controller_name.classify.constantize
    end
  end
end
