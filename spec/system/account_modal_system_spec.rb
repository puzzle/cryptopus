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
    expect(page).to have_css('a.btn.btn-primary', text: 'New Account')
    find('a.btn.btn-primary', text: 'New Account').click

    expect(page).to have_text('New Account')

    expect(page).to have_selector('.modal-content')
    expect(page).to have_text('New Account')
    expect(page).to have_content('Save')

    within('.modal-body.ember-view') do
      expect(page).to have_selector("input[name='cleartextPassword']", visible: false)
    end

    check_password_meter('password', '25')
    check_password_meter('password11', '25')
    check_password_meter('cryptopu', '50')
    check_password_meter('cryptopus1', '75')
    check_password_meter('cryptopus1,0', '100')
    check_password_meter('', '0')

    # Prove that the Passwordfield has no autocomplete
    expect(find("input[name='cleartextPassword']", visible: false)['autocomplete']).to eq 'off'

    fill_modal(account_attrs)

    expect do
      click_button('Save', visible: false)
      expect(page).to have_text(account_attrs[:accountname])
    end.to change { Account.count }.by 1

    # Edit Account
    account = Account.find_by(accountname: account_attrs[:accountname])
    folder = Folder.find(account.folder_id)
    team = Team.find(folder.team_id)

    expect_account_page_with(account_attrs)

    expect(page).to have_selector('#edit_account_button')
    find('#edit_account_button').click

    expect(page).to have_text('Edit Account')

    expect(find('.modal.modal_account')).to be_present
    expect(page).to have_text('Edit Account')
    expect(page).to have_button('Save', visible: false)

    fill_modal(updated_attrs)
    expect_filled_fields_in_modal_with(updated_attrs)
    click_button('Save', visible: false)

    expect_account_page_with(updated_attrs)

    # Delete Account
    expect do
      all('span.btn.btn-light.edit_button[role="button"]')[0].click
      expect(page).to have_text('Are you sure?')
      find('button', text: 'Delete').click
      visit("/teams/#{team.id}/folders/#{folder.id}")

      expect(page).to have_text(team.name)
      expect(page).to have_css('h5', visible: false, text: account.accountname)
    end.to change { Account.count }.by(-1)

    logout
  end

  private

  def fill_modal(acc_attrs)
    within('form.ember-view[role="form"]', visible: false) do
      find("input[name='cleartextPassword']", visible: false).set acc_attrs[:password]
      find("input[name='accountname']", visible: false).set(acc_attrs[:accountname])
      find("input[name='cleartextUsername']", visible: false).set acc_attrs[:username]
      find('textarea.form-control.ember-view', visible: false).set acc_attrs[:description]

      find('#team-power-select', visible: false).find('div.ember-power-select-trigger',
                                                      visible: false).click
      first('ul.ember-power-select-options > li', visible: false).click

      find('#folder-power-select', visible: false).find('div.ember-power-select-trigger',
                                                        visible: false).click
      first('ul.ember-power-select-options > li', visible: false).click
    end
  end

  def expect_account_page_with(acc_attrs)
    expect(page).to have_text("Account: #{acc_attrs[:accountname]}")
    expect(find('#cleartext_username', visible: false).value).to eq(acc_attrs[:username])
    expect(page).to have_text(acc_attrs[:description])
  end

  def expect_filled_fields_in_modal_with(acc_attrs)
    expect(find("input[name='accountname']",
                visible: false).value).to eq(acc_attrs[:accountname])
    expect(find("input[name='cleartextUsername']",
                visible: false).value).to eq(acc_attrs[:username])
    expect(find('textarea.form-control.ember-view',
                visible: false).value).to eq(acc_attrs[:description])
  end

  def check_password_meter(password, expected_score)
    find("input[name='cleartextPassword']", visible: false).set password
    expect(find("div[role='progressbar']", visible: false)['aria-valuenow']).to eq(expected_score)
  end

end
