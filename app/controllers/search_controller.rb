# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class SearchController < ApplicationController

  # GET /search
  def index
    respond_to do |format|
      format.html # new.html.haml
    end
  end

  def account
    term = params[:search_string]

    accounts = current_user.search_accounts(term)

    decrypt_accounts(accounts)
    render json: accounts
  end

  private

  def decrypt_accounts(accounts)
    accounts.each do |a|
      team = a.group.team
      a.decrypt(plaintext_team_password(team))
    end
  end

end
