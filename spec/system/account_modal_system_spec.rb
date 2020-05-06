# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'


describe 'AccountModal', type: :system, js: true do
  include SystemHelpers

  it 'creates, edits and deletes an account' do
    login_as_user(:bob)

    # create Account

    expect(page).to have_link('new Account')
    click_link 'new Account'

    expect(find('.modal-content')).to be_present
    expect(page).to have_text('New Account')
    expect(page).to have_button('Save')

    expect do
      fill_in 'accountname', with: 'test'
      fill_in 'cleartextUsername', with: 'test'
      fill_in 'cleartextPassword', with: 'test'
      fill_in 'description', with: 'test'

      find('#team-power-select').find('.ember-power-select-trigger').click # Open trigger
      find_all('ul.ember-power-select-options > li')[1].click

      find('#group-power-select').find('.ember-power-select-trigger').click # Open trigger
      find_all('ul.ember-power-select-options > li')[1].click

      click_button "Save"
    end.to change {Account.count}.by(1)

    expect(find_field('accountname').value).to eq('accountname')
    expect(find_field('cleartextUsername').value).to eq('username')
    expect(find_field('cleartextPassword').value).to eq('password')
    expect(find('description').value).to eq('desc')

    # TODO
    expect(page).to have_content('Account was successfully created')


    # Edit Account
    account = Account.find_by(accountname: 'accountname')
    visit("/accounts/#{account.id}")



    expect(page).to have_link('Edit-Modal')
    click_link('Edit-Modal')

    expect(find('.modal-content')).to be_present
    expect(page).to have_text('Edit Account')
    expect(page).to have_button('Save')

    expect(find_field('accountname').value).to eq('accountname')
    expect(find('cleartextUsername').value).to eq('username')
    expect(find('cleartextPassword').value).to eq('password')
    expect(find('description').value).to eq('description')

    fill_in 'accountname', with: 'accountname2'
    fill_in 'cleartextUsername', with: 'username2'
    fill_in 'cleartextPassword', with: 'password2'
    fill_in 'description', with: 'description2'

    find('#team-power-select').find('.ember-power-select-trigger').click # Open trigger
    find_all('ul.ember-power-select-options > li')[1].click

    find('#group-power-select').find('.ember-power-select-trigger').click # Open trigger
    find_all('ul.ember-power-select-options > li')[1].click

    click_button "Save"

    expect(first('h1')).to have_text('Account: accountname2')
    expect(find('#cleartextUsername')).to have_text('username2')
    expect(find('#cleartextPassword')).to have_text('password2')
    expect(page).to have_text('description2')

    # Delete Account
    group = Group.find_by(id: account.group_id)
    team = Team.find_by(id: group.team_id)
    find(:xpath, "//a[@href='/team/#{group.team_id}/groups/#{account.group_id}']").click

    expect(find('h1')).to have_text("Accounts in group #{group.name} for team #{team.name}")

    expect(find(:xpath, "//a[@href='/accounts/#{account.group_id}', data-method='delete']")).to be_present

  end

end
