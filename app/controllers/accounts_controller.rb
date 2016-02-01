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

require 'ldap_tools'

class AccountsController < ApplicationController
  before_filter :load_parents

  # GET /teams/1/groups/1/accounts
  def index
    accounts_breadcrumbs
    add_breadcrumb @group.label

    @accounts = @group.accounts.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /teams/1/groups/1/accounts/1
  def show
    @account = Account.find(params[:id])
    @items = @account.items.load

    accounts_breadcrumbs
    add_breadcrumb @group.label, :team_group_accounts_path
    add_breadcrumb @account.label

    @account.decrypt(get_team_password(@team))

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /teams/1/groups/1/accounts/new
  def new
    @account = @group.accounts.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /teams/1/groups/1/accounts
  def create
    @account = @group.accounts.new( account_params )

    @account.encrypt(get_team_password(@team))

    respond_to do |format|
      if @account.save
        flash[:notice] = t('flashes.accounts.created')
        format.html { redirect_to team_group_accounts_url(@team, @group) }
      else
        format.html { render action: 'new' }
      end
    end
  end

  # GET /teams/1/groups/1/accounts/1/edit
  def edit
    @account = @group.accounts.find( params[:id] )
    @groups = @team.groups.all

    accounts_breadcrumbs
    add_breadcrumb @group.label, :team_group_accounts_path
    add_breadcrumb @account.label

    @account.decrypt(get_team_password(@team))

    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  # PUT /teams/1/groups/1/accounts/1
  def update
    @account = @group.accounts.find( params[:id] )
    @account.attributes = account_params

    @account.encrypt(get_team_password(@team))

    respond_to do |format|
      if @account.save
        flash[:notice] = t('flashes.accounts.updated')
        format.html { redirect_to team_group_accounts_url(@team, @group) }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /teams/1/groups/1/accounts/1
  def destroy
    @account = @group.accounts.find( params[:id] )
    @account.destroy

    respond_to do |format|
      format.html { redirect_to team_group_accounts_url(@team, @group) }
    end
  end

  private

    def account_params
      params.require(:account).permit(:accountname, :cleartext_username, :cleartext_password, :description, :group_id)
    end

    def load_parents
      @team = Team.find( params[:team_id] )
      @group = @team.groups.find( params[:group_id] )
    end

    def accounts_breadcrumbs
      add_breadcrumb I18n.t('teams.title'), :teams_path
      add_breadcrumb @team.label, :team_groups_path
    end

end
