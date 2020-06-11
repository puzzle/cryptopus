# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'
describe 'User login' do
  include IntegrationHelpers::DefaultHelper
  it 'logs bob in' do
    login_as('bob')
    expect(request.fullpath).to eq(search_path)
  end

  it 'logs bob in with spaces in username' do
    login_as('   bob   ')
    expect(request.fullpath).to eq(search_path)
  end

  it 'logs bob in with wrong password' do
    login_as('bob', 'wrong_password')
    expect(flash[:error]).to include('Authentication failed')
    expect(request.fullpath).to eq(session_new_path)
  end

  it 'does not login root' do
    login_as('root')
    expect(flash[:error]).to include('Authentication failed')
    expect(request.fullpath).to eq(session_new_path)
  end

  it 'logs bob out' do
    login_as('bob')
    get session_destroy_path
    follow_redirect!
    expect(request.fullpath).to eq(session_new_path)
  end

  it 'jumps to is set when autologout' do
    login_as('bob')
    get session_destroy_path(jumpto: admin_users_path)
    follow_redirect!
    expect(request.fullpath).to eq(session_new_path)
    expect(admin_users_path).to eq(session[:jumpto])
  end

  it 'goes to requested page after login' do
    account = accounts(:account1)
    account1_path = account_path(account)
    get account1_path
    follow_redirect!
    expect(request.fullpath).to eq(session_new_path)
    login_as('bob')
    expect(request.fullpath).to eq(account1_path)
  end

  it 'should reset session after login' do
    get session_new_path
    old_session_id = session.id
    login_as('bob')
    expect(old_session_id).to_not eq(session.id)
  end
end
