# frozen_string_literal: true

# == Schema Information
#
# Table name: file_entries
#
#  id           :integer          not null, primary key
#  encryptable_id   :integer          default(0), not null
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
  let(:credentials1) { encryptables(:credentials1) }

  context 'GET index' do
    it 'shows all file_entries of credential1' do
      login_as(:bob)

      get :index, params: { encryptable_id: credentials1.id }

      expect(response).to have_http_status(200)
      expect(data.count).to eq(2)
      file_attributes = data.first['attributes']
      expect(file_attributes['filename']).to eq('file_entry1')
    end
  end

  context 'POST create' do
    it 'does upload file' do
      login_as(:bob)

      file = fixture_file_upload('test_file.txt', 'text/plain')
      file_entry_params = {
        encryptable_id: credentials1.id,
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
      file_entry.decrypt(team1_password)
      file_content = fixture_file_upload('test_file.txt', 'text/plain').read
      expect(file_entry.cleartext_file).to eq file_content
    end

    it 'does not upload empty file' do
      login_as(:bob)

      file = fixture_file_upload('empty.txt', 'text/plain')
      file_entry_params = {
        encryptable_id: credentials1.id,
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

      file_entry_params = {}

      expect do
        post :create, params: { encryptable_id: credentials1, file_entry: file_entry_params }
      end.to change { FileEntry.count }.by(0)

      expect(response).to have_http_status(422)
    end
  end
end
