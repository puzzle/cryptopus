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

    account_attr = {accountname: 'acc', username: 'username', password: 'password', description: 'desc'}
    account_attr_edited = {accountname: 'acc2', username: 'username2', password: 'password2', description: 'desc2'}

    # Create Account
    expect(page).to have_link('new Account')
    click_link 'new Account'

    expect(find('.modal-content')).to be_present
    expect(page).to have_text('New Account')
    expect(page).to have_button('Save')

    expect do
      fill_modal(account_attr)
      click_button "Save"
    end.to change {Account.count}.by(1)

    expect_account_page_with(account_attr)

    # Edit Account
    account = Account.find_by(accountname: account_attr[:accountname])
    group = Group.find_by(id: account.group_id)
    team = Team.find_by(id: group.team_id)
    visit("/accounts/#{account.id}")

    expect(page).to have_link(id: 'edit_account_button')
    click_link(id: 'edit_account_button')

    expect(find('.modal-content')).to be_present
    expect(page).to have_text('Edit Account')
    expect(page).to have_button('Save')

    expect_filled_fields_in_modal_with(account_attr)

    fill_modal(account_attr_edited)
    click_button "Save"

    expect_account_page_with(account_attr_edited)

    # Delete Account
    find(:xpath, "//a[@href='/teams/#{group.team_id}/groups/#{account.group_id}']").click
    expect(find('h1')).to have_text("Accounts in group #{group.name} for team #{team.name}")

    # Still an async issue. So sometimes test passes, sometimes not.
    expect do
      accept_prompt(wait: 10) do
        delete_button = find(:xpath, "//a[@href='/accounts/#{account.id}' and @data-method='delete']")
        expect(delete_button).to be_present
        delete_button.click
      end
    end.to change {Account.count}.by(-1)

  end

  private

  def fill_modal(account_attr)
    fill_in 'accountname', with: account_attr[:accountname]
    fill_in 'cleartextUsername', with: account_attr[:username]
    fill_in 'cleartextPassword', with: account_attr[:password]
    fill_in 'description', with: account_attr[:description]

    find('#team-power-select').find('.ember-power-select-trigger').click # Open trigger
    find_all('ul.ember-power-select-options > li')[0].click

    find('#group-power-select').find('.ember-power-select-trigger').click # Open trigger
    find_all('ul.ember-power-select-options > li')[0].click
  end

  def expect_account_page_with(account_attr)
    expect(first('h1')).to have_text("Account: #{account_attr[:accountname]}")
    expect(find('#cleartext_username').value).to eq(account_attr[:username])
    expect(find('#cleartext_password').value).to eq(account_attr[:password])
    expect(page).to have_text(account_attr[:description])
  end

  def expect_filled_fields_in_modal_with(account_attr)
    expect(find_field('accountname').value).to eq(account_attr[:accountname])
    expect(find_field('cleartextUsername').value).to eq(account_attr[:username])
    expect(find_field('cleartextPassword').value).to eq(account_attr[:password])
    expect(find('.vertical-resize').value).to eq(account_attr[:description])
  end

end