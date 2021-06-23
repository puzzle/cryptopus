# frozen_string_literal: true

# == Schema Information
#
# Table name: file_entries
#
#  id           :integer          not null, primary key
#  account_id   :integer          default(0), not null
#  description  :text
#  file         :binary
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  filename     :text             not null
#  content_type :text             not null
#

require 'spec_helper'

describe Api::FileEntriesController do
  include ControllerHelpers

  let(:bob) { users(:bob) }
  let(:private_key) { bob.decrypt_private_key('password') }
  let(:plaintext_team_password) { teams(:team1).decrypt_team_password(bob, private_key) }

  context 'GET index' do
    it 'shows all file_entries of account1' do
      login_as(:bob)
      account1 = accounts(:account1)

      get :index, params: { account_id: account1.id }

      expect(response).to have_http_status(200)
      expect(data.count).to eq(2)
      file_attributes = data.first['attributes']
      expect(file_attributes['filename']).to eq('file_entry1')
    end
  end

  context 'POST create' do
    it 'does upload file' do
      login_as(:bob)
      account1 = accounts(:account1)

      file = fixture_file_upload('test_file.txt', 'text/plain')
      file_entry_params = {
        account_id: account1.id,
        content_type: 'application/zip',
        file: file,
        description: 'test'
      }

      expect do
        post :create, params: file_entry_params, xhr: true
      end.to change { FileEntry.count }.by(1)

      file_entry = FileEntry.find_by(filename: 'test_file.txt')

      expect(response).to have_http_status(201)
      expect(file_entry.description).to eq file_entry_params[:description]
      file_entry.decrypt(plaintext_team_password)
      file_content = fixture_file_upload('test_file.txt', 'text/plain').read
      expect(file_entry.cleartext_file).to eq file_content
    end

    it 'does not upload empty file' do
      login_as(:bob)
      account1 = accounts(:account1)

      file = fixture_file_upload('empty.txt', 'text/plain')
      file_entry_params = {
        account_id: account1.id,
        content_type: 'application/zip',
        file: file,
        description: 'test'
      }

      expect do
        post :create, params: file_entry_params, xhr: true
      end.to change { FileEntry.count }.by(0)

      expect(response).to have_http_status(422)

      expect(errors.first['detail']).to eq 'File is inexistent'
    end

    it 'does not upload if no file and no file entry params exist' do
      login_as(:bob)
      account1 = accounts(:account1)

      file_entry_params = {}

      expect do
        post :create, params: { account_id: account1, file_entry: file_entry_params }
      end.to change { FileEntry.count }.by(0)

      expect(response).to have_http_status(422)
    end
  end
end
