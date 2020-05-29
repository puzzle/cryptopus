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

  # DELETE /accounts/1
  def destroy
    authorize account

    @account.destroy
    respond_to do |format|
      format.html { redirect_to team_group_url(team, @group) }
    end
  end

  private

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
end
