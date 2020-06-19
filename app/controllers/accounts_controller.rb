# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.
class AccountsController < ApplicationController

  helper_method :team, :folder
  self.permitted_attrs = [:accountname, :cleartext_username, :cleartext_password,
                          :tag, :description, :folder_id]

  # GET /accounts/1
  def show
    authorize account
    @file_entries = account.file_entries.load

    accounts_breadcrumbs

    account.decrypt(plaintext_team_password(team))

    respond_to do |format|
      format.html # show.html.haml
    end
  end

  private

  def folder
    @folder ||= @account.folder
  end

  def team
    @team ||= folder.team
  end

  def account
    @account ||= Account.find(params[:id])
  end

  def accounts_breadcrumbs
    teams_breadcrumbs

    add_breadcrumb folder.label, team_folder_path(team.id, folder.id)
    add_breadcrumb account.label
  end

  def teams_breadcrumbs
    add_breadcrumb t('teams.title'), :teams_path
    add_breadcrumb team.label, team_path(team.id)
  end
end
