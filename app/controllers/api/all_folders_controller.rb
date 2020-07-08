# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Api::AllFoldersController < ApiController
  self.custom_model_class = Folder

  def self.policy_class
    FolderPolicy
  end

  private

  def fetch_entries
    return current_user.folders if query_param.blank?

    finder(current_user.folders, query_param).apply
  end

  def finder(folders, query)
    Finders::FoldersFinder.new(folders, query)
  end

  def query_param
    params[:q]
  end

  def entry_url
    '#/all_folders'
  end

end
