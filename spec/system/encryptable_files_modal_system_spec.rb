# frozen_string_literal: true

require 'spec_helper'

describe 'Encryptable Files Modal', type: :system, js: true do
  include SystemHelpers

  let(:bob) { users(:bob) }
  let(:bobs_private_key) { bob.decrypt_private_key('password') }
  let(:plaintext_team_password) { teams(:team1).decrypt_team_password(bob, bobs_private_key) }

  it 'creates and deletes a file entry' do
    login_as_user(:bob)

    team = teams(:team1)
    team_password = team.decrypt_team_password(bob, bobs_private_key)

    credentials = encryptables(:credentials1)
    credentials.decrypt(team_password)
    visit("/encryptables/#{credentials.id}")

    expect_encryptable_page_with(credentials, true)

    # Create File Entry
    file_name = 'test_file.txt'
    file_desc = 'description'
    file_path = "#{Rails.root}/spec/fixtures/files/#{file_name}"
    expect do
      create_new_file(file_desc, file_path)
      expect(page).to have_text(credentials.name)
    end.to change { Encryptable::File.count }.by(1)

    file = Encryptable::File.find_by(name: 'test_file.txt')
    file_content = fixture_file_upload(file_path, 'text/plain').read
    file.decrypt(plaintext_team_password)
    expect(file.cleartext_file).to eq file_content

    expect_encryptable_page_with(credentials, false)

    # Try to upload again
    expect do
      create_new_file(file_desc, file_path)
    end.to change { Encryptable::File.count }.by(0)
    expect(page).to have_text('File name has already been taken')
    click_button('Close')

    expect(page).to have_text("Credentials: #{credentials.name}")

    within(find('table.table.table-striped')) do
      # Delete File Entry
      del_button = all('img.icon-button.d-inline[alt="delete"]')[1]
      expect(del_button).to be_present

      del_button.click
      find('button', text: 'Delete').click
      expect(all('tr').count).to eq(2)
    end
  end

  private

  def create_new_file(description, file_path)
    new_file_button = find('button.btn.btn-primary', text: 'Add attachment', visible: false)
    new_file_button.click

    expect(page).to have_text('Add new attachment to credentials')

    expect(find('.modal-content')).to be_present
    expect(page).to have_button('Upload', disabled: true)

    within('div.modal-content') do
      fill_in 'description', with: description
      find(:xpath, "//input[@type='file']", visible: false).attach_file(file_path)
    end

    click_button 'Upload'
  end

  def expect_encryptable_page_with(credentials, first_run)
    expect(first('h2')).to have_text("Credentials: #{credentials.name}")
    expect(find('#cleartext_username').value).to eq(credentials.cleartext_username)
    find('#show-password').click if first_run
    expect(find('#cleartext_password').value).to eq(credentials.cleartext_password)
    expect(page).to have_text(credentials.description)
  end

end
