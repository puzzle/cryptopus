# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class FileEntriesController < ApplicationController
  self.permitted_attrs = [:description, :file]

  helper_method :team

  # POST /accounts/1/file_entries/1
  def show
    @file_entry = account.file_entries.find(params[:id])
    authorize @file_entry

    file = @file_entry.decrypt(plaintext_team_password(team))

    send_data file, filename: @file_entry.filename,
                    type: @file_entry.content_type, disposition: 'attachment'
  end

  # DELETE /accounts/1/file_entries/1
  def destroy
    @file_entry = account.file_entries.find(params[:id])
    authorize @file_entry

    @file_entry.destroy

    respond_to do |format|
      format.html { redirect_to account_url(@account) }
    end
  end

  private

  def account
    @account = Account.find(params[:account_id])
  end

  def folder
    @folder ||= account.folder
  end

  def team
    @team ||= folder.team
  end

  def create_file_entry(format)
    file_entry = FileEntry.create(account, model_params, plaintext_team_password(team))
    if file_entry.errors.empty?
      flash[:notice] = t('flashes.file_entries.uploaded')
      format.html { redirect_to account_url(account) }
    else
      @file_entry = file_entry
      format.html { render action: 'new' }
    end
  end

end
