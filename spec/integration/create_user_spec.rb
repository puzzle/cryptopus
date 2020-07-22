# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'
describe 'Create user' do
  include IntegrationHelpers::DefaultHelper

  context 'as admin' do
    xit 'creates new user' do
      login_as('admin')
      post admin_users_path, params: { user_human: {
        username: 'simon',
        password: 'password',
        role: :user,
        givenname: 'Simon',
        surname: 'Kern'
      } }
      expect(response).to redirect_to admin_users_path
      expect(User::Human.find_by(username: 'simon')).to_not be_nil
      logout
      login_as('simon')
    end

    xit 'cannot create second user bob' do
      login_as('admin')
      post admin_users_path, params: { user_human: {
        username: 'bob',
        password: 'password',
        role: :user,
        givenname: 'Bob',
        surname: ' do'
      } }
      expect(request.fullpath).to eq(admin_users_path)
      expect(response.body).to include('Username has already been taken')
    end
  end

  context 'as bob' do
    xit 'cannot create new user' do
      login_as('bob')
      post admin_users_path, params: { user_human: {
        username: 'rsiegfried',
        password: 'password',
        role: :user,
        givenname: 'Roland',
        surname: 'Siegfried'
      } }
      expect(response).to redirect_to root_path
      expect(User::Human.find_by(username: 'rsiegfried')).to be_nil
    end
  end
end
