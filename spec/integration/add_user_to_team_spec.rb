# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'spec_helper'
describe 'Add user to team' do
  include IntegrationHelpers::DefaultHelper
  it 'adds alice to team as bob' do
    teammembers(:team1_alice).destroy

    credential = encryptables(:credentials1)
    encryptable_path = api_encryptable_path(credential.id)
    cannot_access_encryptable(encryptable_path, 'alice')

    login_as('bob')
    path = api_team_members_path(team_id: teams(:team1))
    post path, params: { data: { attributes: { user_id: users(:alice).id } } }, xhr: true
    logout

    can_access_encryptable(encryptable_path, 'alice', 'password', 'test', 'password')
  end
end
