# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.
class Api::FileEntriesController < ApiController
  self.permitted_attrs = [:filename, :description, :account_id, :file]

  helper_method :team

  # GET /accounts/1/file_entries
  def index(options = {})
    authorize(team, :team_member?, policy_class: TeamPolicy)
    render({ json: fetch_entries,
             each_serializer: list_serializer,
             root: model_root_key.pluralize }
           .merge(render_options)
           .merge(options.fetch(:render_options, {})))
  end

  # GET /accounts/1/file_entries/1
  def show
    authorize entry

    file = entry.decrypt(plaintext_team_password(team))

    send_data file, filename: entry.filename,
                    type: entry.content_type, disposition: 'attachment'
  end

  private

  def fetch_entries
    account.file_entries
  end

  def build_entry
    instance_variable_set(:"@#{ivar_name}",
                          FileEntry.create(account, model_params, plaintext_team_password(team)))
  end

  def account
    @account ||= Account.find(params[:account_id])
  end

  def team
    @team ||= account.folder.team
  end

  def finder(accounts, query)
    Finders::AccountsFinder.new(accounts, query)
  end

  def query_param
    params[:q]
  end

  def tag_param
    params[:tag]
  end

  def model_params
    params.permit(permitted_attrs)
  end
end
