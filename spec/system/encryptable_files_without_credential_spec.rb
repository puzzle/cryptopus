# frozen_string_literal: true

require 'spec_helper'

describe 'Encryptable Files without credentials', type: :system, js: true do
  include SystemHelpers

  let(:bob) { users(:bob) }
  let(:bobs_private_key) { bob.decrypt_private_key('password') }
  let(:plaintext_team_password) { teams(:team2).decrypt_team_password(bob, bobs_private_key) }

  it 'creates a file in folder' do
    login_as_user(:bob)

    visit('/')

    # Create File Entry
    file_name = 'test_file.txt'
    file_desc = 'description'
    file_path = "#{Rails.root}/spec/fixtures/files/#{file_name}"
    expect do
      create_new_file(file_desc, file_path)
      expect(page).to have_text('File was successfully uploaded.')
    end.to change { Encryptable::File.count }.by(1)


    file = Encryptable::File.find_by(name: 'test_file.txt')
    file_content = fixture_file_upload(file_path, 'text/plain').read
    file.decrypt(plaintext_team_password)
    expect(file.cleartext_file).to eq file_content

    # Try to upload file with same name to same folder
    expect do
      create_new_file(file_desc, file_path)
    end.to change { Encryptable::File.count }.by(0)

    expect(page).to have_text('File name has already been taken')
    click_button('Close')
  end

  private

  def create_new_file(description, file_path)
    dropdown_toggle = find('.search .dropdown a', text: 'Add')
    dropdown_toggle.click
    new_file_button = find('.dropdown-item', text: 'New File')
    new_file_button.click

    expect(page).to have_text('Upload new file')

    expect(find('.modal-content')).to be_present
    expect(page).to have_button('Upload', disabled: true)

    select_team_and_folder

    within('div.modal-content') do
      fill_in 'description', with: description
      find(:xpath, "//input[@type='file']", visible: false).attach_file(file_path)
    end
    click_button 'Upload'
  end

  def select_team_and_folder
    find('#team-dropdown', visible: false).click
    all('ul.ember-power-select-options > li', visible: false).last.click

    find('#folder-dropdown', visible: false).click
    first('ul.ember-power-select-options > li', visible: false).click
  end

end
