# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'
describe 'Create team' do
  include IntegrationHelpers::DefaultHelper
  include IntegrationHelpers::AccountTeamSetupHelper

  context 'as bob' do
    it 'creates new normal team' do
      # Setup for test
      account = create_team_folder_account('bob', 'password')

      # Create account link
      account_path = api_account_path(account)


      # Bob can access team / accounts
      can_access_account(account_path, 'bob')

      # Root can access team / account
      can_access_account(account_path, 'root')

      # Admin can access team / account
      can_access_account(account_path, 'admin')
    end

    it 'creates private team' do
      # Setup for test
      account = create_team_folder_account_private('bob', 'password')

      # Create account link
      account_path = api_account_path(account)

      # Bob can not access team / accounts
      can_access_account(account_path, 'bob')

      # Admin can not access team / account
      cannot_access_account(account_path, 'admin')
    end
  end

  private

  def account_path(account = nil)
    return '/accounts' if account.nil?

    "/accounts/#{account.id}"
  end
end
