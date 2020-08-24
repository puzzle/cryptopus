# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Api::FoldersController < ApiController

  self.permitted_attrs = [:name, :description, :team_id]

  def self.policy_class
    FolderPolicy
  end

  # GET /api/folders
  def index
    authorize team, :team_member?
    super
  end

  def show(options = {})
    super({ render_options: { serializer: FolderMinimalSerializer }})
  end

  private

  def fetch_entries
    return team.folders if query_param.blank?

    finder(team.folders, query_param).apply
  end

  def finder(folders, query)
    Finders::FoldersFinder.new(folders, query)
  end

  def query_param
    params[:q]
  end
end
