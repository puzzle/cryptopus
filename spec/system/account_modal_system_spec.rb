# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'


describe 'AccountModal', type: :system, js: true do
  include SystemHelpers

  let(:account_attrs) do
    { accountname: 'acc',
      username: 'username',
      password: 'password',
      description: 'desc' }
  end

  let(:updated_attrs) do
    { accountname: 'acc2',
      username: 'username2',
      password: 'password2',
      description: 'desc2' }
  end

  it 'creates, edits and deletes an account' do
    safe_password = "AbC3_1AbC!"
    login_as_user(:bob)

    # Create Account
    expect(page).to have_link('new Account')
    click_link 'new Account'

    expect(find('.modal-content')).to be_present
    expect(page).to have_text('New Account')
    expect(page).to have_button('Save')

    expect(find('div.ember-progress-bar').find('path')[:style]).to eq("stroke-dasharray: 100px, 100px; stroke-dashoffset: 99px;")

    fill_in 'cleartextPassword', with: safe_password

    expect(find('div.ember-progress-bar').find('path')[:style]).to eq("stroke-dasharray: 100px, 100px; stroke-dashoffset: 25px;")

    expect do
      fill_modal(account_attrs)
      click_button 'Save'
    end.to change { Account.count }.by(1)


    expect_account_page_with(account_attrs)

    # Edit Account
    account = Account.find_by(accountname: account_attrs[:accountname])
    group = Group.find(account.group_id)
    team = Team.find(group.team_id)
    visit("/accounts/#{account.id}")

    expect(page).to have_link(id: 'edit_account_button')
    click_link(id: 'edit_account_button')

    expect(find('.modal-content')).to be_present
    expect(page).to have_text('Edit Account')
    expect(page).to have_button('Save')

    expect_filled_fields_in_modal_with(account_attrs)

    fill_modal(updated_attrs)
    click_button 'Save'

    expect_account_page_with(updated_attrs)

    # Delete Account
    find(:xpath, "//a[@href='/teams/#{group.team_id}/groups/#{account.group_id}']").click
    expect(find('h1')).to have_text("Accounts in group #{group.name} for team #{team.name}")

    # Still an async issue. So sometimes test passes, sometimes not.
    expect do
      del_button = find(:xpath, "//a[@href='/accounts/#{account.id}' and @data-method='delete']")
      expect(del_button).to be_present

      accept_prompt(wait: 3) do
        del_button.click
      end

      expect(find('h1')).to have_text("Accounts in group #{group.name} for team #{team.name}")
    end.to change { Account.count }.by(-1)

  end

  private

  def fill_modal(acc_attrs)
    within('div.modal-content') do
      fill_in 'accountname', with: (acc_attrs[:accountname])
      fill_in 'cleartextUsername', with: acc_attrs[:username]
      fill_in 'cleartextPassword', with: acc_attrs[:password]
      fill_in 'description', with: acc_attrs[:description]

      find('#team-power-select').find('.ember-power-select-trigger').click # Open trigger
      find_all('ul.ember-power-select-options > li')[0].click

      find('#group-power-select').find('.ember-power-select-trigger').click # Open trigger
      find_all('ul.ember-power-select-options > li')[0].click
    end
  end

  def expect_account_page_with(acc_attrs)
    expect(first('h1')).to have_text("Account: #{acc_attrs[:accountname]}")
    expect(find('#cleartext_username').value).to eq(acc_attrs[:username])
    expect(find('#cleartext_password').value).to eq(acc_attrs[:password])
    expect(page).to have_text(acc_attrs[:description])
  end

  def expect_filled_fields_in_modal_with(acc_attrs)
    expect(find_field('accountname').value).to eq(acc_attrs[:accountname])
    expect(find_field('cleartextUsername').value).to eq(acc_attrs[:username])
    expect(find_field('cleartextPassword').value).to eq(acc_attrs[:password])
    expect(find('.vertical-resize').value).to eq(acc_attrs[:description])
  end

end
