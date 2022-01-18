# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'spec_helper'
describe 'Account attachement' do
  include IntegrationHelpers::DefaultHelper
  it 'adds and removes attachment to account1' do
    credential = encryptables(:credentials1)
    login_as('bob')
    file = fixture_file_upload('test_file.txt', 'text/plain')

    file_entry_path = api_encryptable_file_entries_path(encryptable_id: credential.id)
    file_entry_params = {
      encryptable_id: credential.id,
      file: file,
      description: 'test'
    }
    expect do
      post file_entry_path,
           params: file_entry_params
    end.to change { FileEntry.count }.by(1)
    logout

    login_as('alice')
    file = credential.file_entries.find_by(filename: 'test_file.txt')
    file_entry_path = api_encryptable_file_entry_path(credential, file)
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
