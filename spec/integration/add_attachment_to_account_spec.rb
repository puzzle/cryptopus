# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'
describe 'Account attachement' do
  include IntegrationHelpers::DefaultHelper
  it 'adds and removes attachment to account1' do
    account = accounts(:account1)
    login_as('bob')
    file = fixture_file_upload('files/test_file.txt', 'text/plain')

    file_entry_path = api_account_file_entries_path(account_id: account.id)
    file_entry_params = {
      account_id: account.id,
      file: file,
      description: 'test'
    }
    expect do
      post file_entry_path,
           params: file_entry_params
    end.to change { FileEntry.count }.by(1)
    logout

    login_as('alice')
    file = account.file_entries.find_by(filename: 'test_file.txt')
    file_entry_path = account_file_entry_path(account, file)
    get file_entry_path
    expect(response.body).to eq('certificate')
    expect(response.header['Content-Type']).to eq('text/plain')
    expect(response.header['Content-Disposition']).to include('test_file.txt')
    expect do
      delete file_entry_path
    end.to change { FileEntry.count }.by(-1)
    logout

    expect(FileEntry.exists?(file.id)).to be false
  end
end
