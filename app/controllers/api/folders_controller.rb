# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Api::FoldersController < ApiController

  def self.policy_class
    FolderPolicy
  end

  # GET /api/folders
  def index
    authorize Folder
    folders = current_user.folders
    render_json find_folders(folders)
  end

  private

  def find_folders(folders)
    if query_param.present?
      folders = finder(folders, query_param).apply
    end
    folders
  end

  def finder(folders, query)
    Finders::FoldersFinder.new(folders, query)
  end

  def query_param
    params[:q]
  end
end
