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

    visit '/teams'

    # Create Account
    expect(page).to have_link('New Account')
    click_link 'New Account'

    expect(page).to have_selector('.modal-content')
    expect(page).to have_text('New Account')
    expect(page).to have_content('Save')

    within('.modal-body.ember-view') do
      expect(page).to have_selector('input#cleartext-password')
    end

    check_password_meter('password', '25')
    check_password_meter('password11', '25')
    check_password_meter('cryptopu', '50')
    check_password_meter('cryptopus1', '75')
    check_password_meter('cryptopus1,0', '100')
    check_password_meter('', '0')

    expect do
      fill_modal(account_attrs)
      click_button('Save', visible: false)
    end.to change { Account.count }.by(1)

    # Edit Account
    account = Account.find_by(accountname: account_attrs[:accountname])
    folder = Folder.find(account.folder_id)
    team = Team.find(folder.team_id)

    expect_account_page_with(account_attrs)

    expect(page).to have_link(id: 'edit_account_button')
    click_link(id: 'edit_account_button')

    expect(find('.modal.modal_account')).to be_present
    expect(page).to have_text('Edit Account')
    expect(page).to have_button('Save', visible: false)

    fill_modal(updated_attrs)
    asdf
    expect_filled_fields_in_modal_with(updated_attrs)
    click_button('Save', visible: false)

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
    within('div.modal_account') do
      find('input#accountname', visible: false).set('').set(acc_attrs[:accountname])
      find('input#username', visible: false).set('').set acc_attrs[:username]
      find('input#cleartext-password', visible: false).set('').set acc_attrs[:password]
      find('textarea#description', visible: false).set('').set acc_attrs[:description]

      # rubocop:disable Layout/LineLength
      find('#team-power-select').find('div.ember-view.ember-basic-dropdown-trigger.ember-basic-dropdown-trigger--in-place.ember-power-select-trigger', visible: false).click # Open trigger
      first('ul.ember-power-select-options > li').click

      find('#folder-power-select').find('div.ember-view.ember-basic-dropdown-trigger.ember-basic-dropdown-trigger--in-place.ember-power-select-trigger', visible: false).click # Open trigger
      first('ul.ember-power-select-options > li', visible: false).click
      # rubocop:enable Layout/LineLength
    end
  end

  def expect_account_page_with(acc_attrs)
    expect(first('h1')).to have_text("Account: #{acc_attrs[:accountname]}")
    expect(find('#cleartext_username').value).to eq(acc_attrs[:username])
    find('a.show-password-link', visible: false).click
    expect(find('#cleartext_password', visible: false).value).to eq(acc_attrs[:password])
    expect(page).to have_text(acc_attrs[:description])
  end

  def expect_filled_fields_in_modal_with(acc_attrs)
    expect(find_field('accountname').value).to eq(acc_attrs[:accountname])
    expect(find("input[name='username']",
                visible: false).value).to eq(acc_attrs[:username])
    expect(find("input[name='cleartext-password']",
                visible: false).value).to eq(acc_attrs[:password])
    expect(find('.vertical-resize', visible: false).value).to eq(acc_attrs[:description])
  end

  def check_password_meter(password, expected_score)
    find("input[name='cleartext-password']", visible: false).set password
    expect(find("div[role='progressbar']", visible: false)['aria-valuenow']).to eq(expected_score)
  end

end
