#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class AccountsController < ApplicationController
  before_action :group
  helper_method :team

  # GET /teams/1/groups/1/accounts
  def index
    authorize team, :team_member?
    skip_policy_scope

    accounts_breadcrumbs

    @accounts = AccountPolicy::Scope.new(current_user, @group).resolve

    respond_to do |format|
      format.html # index.html.haml
    end
  end

  # GET /teams/1/groups/1/accounts/1
  def show
    @account = Account.find(params[:id])
    authorize @account
    @items = @account.items.load

    accounts_breadcrumbs

    @account.decrypt(plaintext_team_password(team))

    respond_to do |format|
      format.html # show.html.haml
    end
  end

  # GET /teams/1/groups/1/accounts/new
  def new
    @account = @group.accounts.new
    authorize @account

    respond_to do |format|
      format.html # new.html.haml
    end
  end

  # POST /teams/1/groups/1/accounts
  def create
    @account = @group.accounts.new(account_params)
    authorize @account

    @account.encrypt(plaintext_team_password(team))

    respond_to do |format|
      save_account(format)
    end
  end

  # GET /teams/1/groups/1/accounts/1/edit
  def edit
    @account = @group.accounts.find(params[:id])
    authorize @account

    @groups = team.groups.all

    accounts_breadcrumbs

    @account.decrypt(plaintext_team_password(team))

    respond_to do |format|
      format.html # edit.html.haml
    end
  end

  # PUT /teams/1/groups/1/accounts/1
  def update
    update_account

    respond_to do |format|
      if @account.save
        flash[:notice] = t('flashes.accounts.updated')
        format.html { redirect_to team_group_accounts_url(team, @group) }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /teams/1/groups/1/accounts/1
  def destroy
    @account = @group.accounts.find(params[:id])
    authorize @account
    @account.destroy

    respond_to do |format|
      format.html { redirect_to team_group_accounts_url(team, @group) }
    end
  end

  # PUT /teams/1/groups/1/accounts/1/move
  def move
    @account = Account.find(params[:account_id])
    authorize @account
    respond_to do |format|
      target_group = Group.find(account_params[:group_id])
      move_account(format, target_group)
    end
  end

  private

  def update_account
    @account = @group.accounts.find(params[:id])
    authorize @account
    @account.attributes = account_params
    @account.encrypt(plaintext_team_password(team))
  end

  def move_account(format, target_group)
    if account_move_handler.move(target_group)
      flash[:notice] = t('flashes.accounts.moved')
      format.html { redirect_to team_group_accounts_url(team, @group) }
    else
      @items = @account.items.load
      flash[:error] = @account.errors.full_messages.join
      format.html { render action: 'show' }
    end
  end

  def account_params
    params.require(:account).permit(:accountname,
                                    :cleartext_username,
                                    :cleartext_password,
                                    :tag,
                                    :description,
                                    :group_id)
  end

  def group
    @group ||= team.groups.find(params[:group_id])
  end

  def accounts_breadcrumbs
    add_breadcrumb t('teams.title'), :teams_path
    add_breadcrumb team.label, :team_groups_path

    add_breadcrumb @group.label if action_name == 'index'

    if action_name == 'show' || action_name == 'edit'
      add_breadcrumb @group.label, :team_group_accounts_path
      add_breadcrumb @account.label
    end
  end

  def account_move_handler
    AccountMoveHandler.new(@account, session[:private_key], current_user)
  end

  def save_account(format)
    if @account.save
      flash[:notice] = t('flashes.accounts.created')
      format.html { redirect_to team_group_accounts_url(team, @group) }
    else
      format.html { render action: 'new' }
    end
  end
end
