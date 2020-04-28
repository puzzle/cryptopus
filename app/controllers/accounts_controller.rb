# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.
class AccountsController < ApplicationController

  helper_method :team, :group
  self.permitted_attrs = [:accountname, :cleartext_username, :cleartext_password,
                          :tag, :description, :group_id]

  # GET /accounts/1
  def show
    authorize account
    @items = account.items.load

    accounts_breadcrumbs

    account.decrypt(plaintext_team_password(team))

    respond_to do |format|
      format.html # show.html.haml
    end
  end

  # GET /accounts/new?group_id=42
  def new
    @account = Account.new(group_id: params[:group_id])
    authorize account

    respond_to do |format|
      format.html # new.html.haml
    end
  end

  # POST /accounts
  def create
    @account = Account.new(model_params)
    authorize account
    account.encrypt(plaintext_team_password(team))
    respond_to do |format|
      save_account(format)
    end
  end

  # GET /accounts/1/edit
  def edit
    authorize account
    accounts_breadcrumbs
    @account.decrypt(plaintext_team_password(team))
    respond_to do |format|
      format.html # edit.html.haml
    end
  end

  # PUT /accounts/1
  def update
    authorize account

    update_account
    respond_to do |format|
      if @account.save
        flash[:notice] = t('flashes.accounts.updated')
        format.html { redirect_to team_group_url(team, @group) }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /accounts/1
  def destroy
    authorize account

    @account.destroy
    respond_to do |format|
      format.html { redirect_to team_group_url(team, @group) }
    end
  end

  # PUT /accounts/1/move
  def move
    authorize account

    respond_to do |format|
      target_group = Group.find(model_params[:group_id])
      move_account(format, target_group)
    end
  end

  private

  def update_account
    account.attributes = model_params
    account.encrypt(plaintext_team_password(team))
  end

  def move_account(format, target_group)
    if account_move_handler.move(target_group)
      flash[:notice] = t('flashes.accounts.moved')
      format.html { redirect_to team_group_url(team, @group) }
    else
      @items = @account.items.load
      flash[:error] = @account.errors.full_messages.join
      format.html { render action: 'show' }
    end
  end

  def group
    @group ||= @account.group
  end

  def team
    @team ||= group.team
  end

  def account
    @account ||= Account.find(params[:id])
  end

  def accounts_breadcrumbs
    teams_breadcrumbs

    add_breadcrumb group.label, team_group_path(team.id, group.id)
    add_breadcrumb account.label
  end

  def teams_breadcrumbs
    add_breadcrumb t('teams.title'), :teams_path
    add_breadcrumb team.label, team_path(team.id)
  end

  def account_move_handler
    AccountMoveHandler.new(@account, session[:private_key], current_user)
  end

  def save_account(format)
    if @account.save
      flash[:notice] = t('flashes.accounts.created')
      format.html { redirect_to team_group_url(team.id, group.id) }
    else
      format.html { render action: 'new' }
    end
  end
end
