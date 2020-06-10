# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'


describe 'FileEntryModal', type: :system, js: true do
  include SystemHelpers

  let(:bob) { users(:bob) }
  let(:bobs_private_key) { bob.decrypt_private_key('password') }
  let(:plaintext_team_password) { teams(:team1).decrypt_team_password(bob, bobs_private_key) }

  it 'creates and deletes a file entry' do
    login_as_user(:bob)

    team = teams(:team1)
    team_password = team.decrypt_team_password(bob, bobs_private_key)

    account = accounts(:account1)
    account.decrypt(team_password)
    visit("/accounts/#{account.id}")

    expect_account_page_with(account)

    # Create File Entry
    file_name = 'test_file.txt'
    file_desc = 'description'
    file_path = "#{Rails.root}/spec/fixtures/files/#{file_name}"
    expect do
      create_new_file_entry(file_desc, file_path)
    end.to change { FileEntry.count }.by(1)

    file_entry = FileEntry.find_by(filename: 'test_file.txt')
    file_content = fixture_file_upload(file_path, 'text/plain').read
    file_entry.decrypt(plaintext_team_password)
    expect(file_entry.cleartext_file).to eq file_content

    expect_account_page_with(account)

    # Try to upload again
    expect do
      create_new_file_entry(file_desc, file_path)
    end.to change { FileEntry.count }.by(0)

    expect(page).to have_text('Filename is already taken')
    click_button('Close')

    expect(page).to have_text("Account: #{account.accountname}")

    # Delete Account
    expect do
      href = "/accounts/#{account.id}/file_entries/#{file_entry.id}"
      del_button = find(:xpath, "//a[@href='#{href}' and @data-method='delete']")
      expect(del_button).to be_present

      accept_prompt(wait: 3) do
        del_button.click
      end

      expect(page).to have_text("Account: #{account.accountname}")
    end.to change { FileEntry.count }.by(-1)

  end

  private

  def create_new_file_entry(description, file_path)
    new_file_entry_button = page.find_link('Add attachment')
    new_file_entry_button.click

    expect(find('.modal-content')).to be_present
    expect(page).to have_text('Add new attachment to account')
    expect(page).to have_button('Upload')

    within('div.modal-content') do
      fill_in 'description', with: description
      find(:xpath, "//input[@type='file']", visible: false).attach_file(file_path)
    end

    click_button 'Upload'
  end

  def expect_account_page_with(account)
    expect(first('h1')).to have_text("Account: #{account.accountname}")
    expect(find('#cleartext_username').value).to eq(account.cleartext_username)
    expect(find('#cleartext_password').value).to eq(account.cleartext_password)
    expect(page).to have_text(account.description)
  end

end
