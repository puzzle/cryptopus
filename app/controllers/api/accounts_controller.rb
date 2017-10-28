#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Api::AccountsController < ApiController

  self.api_token_accessible = [:show]

  def self.policy_class
    AccountPolicy
  end

  def index
    accounts = policy_scope(Account)
    accounts = find_accounts(accounts)
    render_json accounts
  end

  def show
    account = Account.find(params['id'])
    authorize account
    account.decrypt(plaintext_team_password(account.group.team))
    render_json account
  end

  private

  def find_accounts(accounts)
    if query_param.present?
      accounts = finder(accounts, query_param).apply
    elsif tag_param.present?
      accounts.find_by(tag: tag_param)
    end
    accounts
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
end
