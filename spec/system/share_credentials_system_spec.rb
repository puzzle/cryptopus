# frozen_string_literal: true

require 'spec_helper'

# Rspec does load somewhat differently, to avoid a autoload error, those are included like that.
require_relative '../../app/controllers/api/user_candidates_controller'


describe 'ShareCredentials', type: :system, js: true do
  include SystemHelpers

  let(:bob) { users(:bob) }
  let(:bobs_private_key) { bob.decrypt_private_key('password') }
  let(:plaintext_team_password) { teams(:team1).decrypt_team_password(bob, bobs_private_key) }

  it 'selects receiver' do
    login_as_user(:bob)
    visit('/')

    team = teams(:team1)
    team_password = team.decrypt_team_password(bob, bobs_private_key)

    credentials = encryptables(:credentials1)
    credentials.decrypt(team_password)
    visit("/encryptables/#{credentials.id}")

    expect_encryptable_page_with(credentials)

    find('#share_credential_button').click

    expect(page).to have_content('Share credentials with')
    expect(page).to have_content("A copy of Personal Mailbox will be sent to the receiver's inbox")

    # Add Admin as receiver

    first('.ember-basic-dropdown-trigger', visible: false).click

    within('.ember-power-select-options', visible: false) do
      find('li', match: :first).click
    end

    find('Button[alt="save"]').click

    expect(page).to have_content('Successfully transferred credentials to recipient')
  end

  def expect_encryptable_page_with(credentials)
    expect(first('h2')).to have_text("Credentials: #{credentials.name}")
    expect(find('#cleartext_username').value).to eq(credentials.cleartext_username)
    find('#show-password').click
    expect(find('#cleartext_password', visible: false).value).to eq(credentials.cleartext_password)
    expect(page).to have_text(credentials.description)
  end
end
