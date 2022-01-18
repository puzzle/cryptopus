# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class FixturesHelper
  class << self
    def read_public_key(user)
      filepath = "users/#{user}/public.key"
      read_file(filepath)
    end

    def read_private_key(user)
      filepath = "users/#{user}/private.key"
      read_file(filepath)
    end

    def read_team_password(user, team)
      filepath = "users/#{user}/#{team}_password.crypt"
      read_file(filepath)
    end

    def read_account_username(team, account)
      filepath = "teams/#{team}/#{account}/username.crypt"
      read_file(filepath)
    end

    def read_account_password(team, account)
      filepath = "teams/#{team}/#{account}/password.crypt"
      read_file(filepath)
    end

    def read_item_file(team, account, item)
      filepath = "teams/#{team}/#{account}/#{item}/file.crypt"
      read_file(filepath)
    end

    def read_encryptable_file(item)
      file_path = "encryptables/#{item}"
      read_file(file_path)
    end

    private

    def read_file(filepath)
      path = "#{Rails.root}/spec/fixtures/files/#{filepath}"
      Base64.strict_encode64(File.open(path, 'rb') { |f| f.read })
    end
  end
end
