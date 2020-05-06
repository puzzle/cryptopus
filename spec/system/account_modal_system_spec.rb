# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'

describe 'AccountModal', type: :system, js: true do
  include SystemHelpers

  before(:each) do

  end

  it 'creates new account' do
    login_as_user(:bob)
    account1 = accounts(:account1)
    visit("/accounts/#{account1.id}")

    expect(page).to have_link('new Account')

    click_link 'new Account'

    #expect(page).to have_title('New Account')
    expect(page).to have_button('Save')
    expect(page).to have_button('Close')

    fill_in 'accountname', with: 'lkj'
    fill_in 'cleartextUsername', with: 'lkj'
    fill_in 'cleartextPassword', with: 'lkj'
    fill_in 'description', with: 'lkj'
    # fill_in 'team', with ''
    # fill_in 'group', with ''


    find('name').find(:xpath, 'option[2]').select_option

    click_button "Save"

    expect(page).to have_content('Account was successfully created')


  end

  it 'edits properties of existing account' do
    login_as_user(:bob)
    account1 = accounts(:account1)
    visit("/accounts/#{account1.id}")

    expect(page).to have_link('Edit-Modal')

    find('#edit_account_button').click

    #expect(page).to have_title('New Account')
    expect(page).to have_button('Save')
    expect(page).to have_button('Close')

    fill_in 'accountname', with: 'accountname'
    fill_in 'cleartextUsername', with: 'username'
    fill_in 'cleartextPassword', with: 'password'
    fill_in 'description', with: 'lkj'

    click_button "Save"

    expect(first('h1')).to have_text('Account: accountname')
    expect(find('#cleartextUsername')).to have_text('username')
    expect(find('#cleartextPassword')).to have_text('password')

  end

  it 'moves account to another team' do



  end
end
