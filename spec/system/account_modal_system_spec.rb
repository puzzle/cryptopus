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
    login_as_user(:bob)

    # Create Account
    expect(page).to have_link('New Account')
    click_link 'New Account'

    expect(find('.modal-content')).to be_present
    expect(page).to have_text('New Account')
    expect(page).to have_button('Save')


    expect(page.find_field('cleartextPassword')).to be_present
    check_password_meter('password', '10')
    check_password_meter('password11', '25')
    check_password_meter('cryptopu', '50')
    check_password_meter('cryptopus1', '75')
    check_password_meter('cryptopus1,0', '100')
    check_password_meter('', '0')

    expect do
      fill_modal(account_attrs)
      click_button 'Save'
    end.to change { Account.count }.by(1)


    expect_account_page_with(account_attrs)

    # Edit Account
    account = Account.find_by(accountname: account_attrs[:accountname])
    folder = Folder.find(account.folder_id)
    team = Team.find(folder.team_id)
    visit("/accounts/#{account.id}")

    expect(page).to have_link(id: 'edit_account_button')
    click_link(id: 'edit_account_button')

    expect(find('.modal-content')).to be_present
    expect(page).to have_text('Edit account')
    expect(page).to have_button('Save')

    expect_filled_fields_in_modal_with(account_attrs)

    fill_modal(updated_attrs)
    click_button 'Save'

    expect_account_page_with(updated_attrs)

    # Delete Account
    find(:xpath, "//a[@href='/teams/#{folder.team_id}/folders/#{account.folder_id}']").click
    expect(find('h1')).to have_text("Accounts in folder #{folder.name} for team #{team.name}")

    expect do
      del_button = find(:xpath, "//a[@href='/accounts/#{account.id}' and @data-method='delete']")
      expect(del_button).to be_present

      accept_prompt(wait: 3) do
        del_button.click
      end

      expect(find('h1')).to have_text("Accounts in folder #{folder.name} for team #{team.name}")
    end.to change { Account.count }.by(-1)

    logout

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

      find('#folder-power-select').find('.ember-power-select-trigger').click # Open trigger
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

  def check_password_meter(password, expected_score)
    fill_in 'cleartextPassword', with: password
    expect(page.find('.progress-bar')['aria-valuenow']).to eq(expected_score)
  end

end
