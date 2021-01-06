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
    current_user.folders
  end

  def query_param
    params[:q]
  end

  def entry_url
    '#/all_folders'
  end

end
