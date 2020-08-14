# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.
class Api::AccountsController < ApiController
  self.permitted_attrs = [:accountname, :description, :cleartext_username, :category,
                          :folder_id, :cleartext_password, :tag]

  helper_method :team

  # GET /api/accounts/:id
  def show
    authorize account
    account.decrypt(decrypted_team_password(team))
    render_entry
  end

  # POST /api/accounts
  def create
    @account = Account.new(model_params)
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
    account.encrypt(decrypted_team_password(team))
    account_move_handler.move if account.folder_id_changed?
    if account.save
      render_json account
    else
      render_errors
    end
  end

  private

  def fetch_entries
    accounts = current_user.accounts
    if query_param.present?
      accounts = finder(accounts, query_param).apply
    elsif tag_param.present?
      accounts = accounts.find_by(tag: tag_param)
    end
    accounts
  end

  def account
    @account ||= Account.find(params[:id])
  end

  def team
    @team ||= account.folder.team
  end

  def finder(accounts, query)
    ::Finders::AccountsFinder.new(accounts, query)
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
end
