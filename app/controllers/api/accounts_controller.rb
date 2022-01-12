# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.
class Api::AccountsController < ApiController
  self.permitted_attrs = [:name, :description, :folder_id, :tag]

  helper_method :team

  # GET /api/accounts
  def index(options = {})
    authorize Account
    render({ json: fetch_entries,
             root: model_root_key.pluralize }
           .merge(render_options)
           .merge(options.fetch(:render_options, {})))
  end

  # GET /api/accounts/:id
  def show
    authorize account
    account.decrypt(decrypted_team_password(team))
    render_entry
  end

  # POST /api/accounts
  def create
    build_entry
    authorize @account
    account.encrypt(decrypted_team_password(team))
    if @account.save
      @response_status = :created
      render_json @account
    else
      render_errors
    end
  end

  # PATCH /api/accounts/:id?Query
  def update
    authorize account
    account.attributes = model_params

    encrypt(account)

    if account.save
      render_json account
    else
      render_errors
    end
  end

  private

  def model_class
    if action_name == 'create' &&
       params.dig('data', 'attributes', 'type') == 'ose_secret'
      Account::OSESecret
    elsif action_name == 'destroy'
      Account
    elsif @account.present?
      @account.class
    else
      Account::Credentials
    end
  end

  def fetch_entries
    accounts = current_user.accounts
    if tag_param.present?
      accounts = accounts.find_by(tag: tag_param)
    end
    accounts
  end

  def encrypt(account)
    if account.folder_id_changed?
      # if folder id changed recheck team permission
      authorize account
      # move handler calls encrypt implicit
      account_move_handler.move
    else
      account.encrypt(decrypted_team_password(team))
    end
  end

  def account
    @account ||= Account.find(params[:id])
  end

  def team
    @team ||= account.folder.team
  end

  def query_param
    params[:q]
  end

  def tag_param
    params[:tag]
  end

  def account_move_handler
    AccountMoveHandler.new(account, session[:private_key], current_user)
  end

  def ivar_name
    Account.model_name.param_key
  end

  def model_serializer
    "#{model_class.name}Serializer".constantize
  end

  def permitted_attrs
    permitted_attrs = self.class.permitted_attrs.deep_dup

    if model_class == Account::OSESecret
      permitted_attrs << :cleartext_ose_secret
    elsif model_class == Account::Credentials
      permitted_attrs + [:cleartext_username, :cleartext_password]
    else
      permitted_attrs
    end
  end
end
