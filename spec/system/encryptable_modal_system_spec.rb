# frozen_string_literal: true

require 'spec_helper'

describe 'encryptable modal', type: :system, js: true do
  include SystemHelpers

  let(:encryptable_attrs) do
    { name: 'acc',
      username: 'username',
      password: 'strong-pass3roeedd-1§23',
      description: 'desc' }
  end

  let(:updated_attrs) do
    { name: 'acc2',
      username: 'username2',
      password: 'strong-pass3roeedd-1§23-zzeu',
      description: 'desc2' }
  end

  it 'creates, edits and deletes credentials' do
    login_as_user(:bob)
    visit('/')

    # Create Credentials
    expect(page).to have_css('div.dropdown-toggle-text span', text: 'Add')
    find('div.dropdown-toggle-text span', text: 'Add').click

    within('div.dropdown-menu') do
      all('a.dropdown-item').first.click
    end

    expect(page).to have_text('New Encryptable')

    expect(page).to have_selector('.modal-content')
    expect(page).to have_text('New Encryptable')
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

    fill_modal(encryptable_attrs)

    expect do
      click_button('Save', visible: false)
      expect(page).to have_text(encryptable_attrs[:name])
    end.to change { Encryptable.count }.by 1

    # Edit Account
    credentials = Encryptable.find_by(name: encryptable_attrs[:name])
    folder = Folder.find(credentials.folder_id)
    team = Team.find(folder.team_id)

    expect_encryptable_page_with(encryptable_attrs)

    find('#edit_account_button').click

    expect(page).to have_text('Edit Encryptable')

    expect(find('.modal.modal_account')).to be_present
    expect(page).to have_text('Edit Encryptable')
    expect(page).to have_button('Save', visible: false)

    fill_modal(updated_attrs)
    expect_filled_fields_in_modal_with(updated_attrs)
    click_button('Save', visible: false)

    expect_encryptable_page_with(updated_attrs)

    # Delete Credentials
    expect do
      all('span.btn.btn-light.edit_button[role="button"]')[0].click
      expect(page).to have_text('Are you sure?')
      find('button', text: 'Delete').click
      visit("/teams/#{team.id}/folders/#{folder.id}")

      expect(page).to have_text(team.name)
      expect(page).not_to have_text(credentials.name)
    end.to change { Encryptable.count }.by(-1)

    logout
  end

  private

  def fill_modal(acc_attrs)
    within('form.ember-view[role="form"]', visible: false) do
      find("input[name='cleartextPassword']", visible: false).set acc_attrs[:password]
      find("input[name='name']", visible: false).set(acc_attrs[:name])
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

  def expect_encryptable_page_with(acc_attrs)
    expect(page).to have_text("Encryptable: #{acc_attrs[:name]}")
    expect(find('#cleartext_username', visible: false).value).to eq(acc_attrs[:username])
    expect(page).to have_text(acc_attrs[:description])
  end

  def expect_filled_fields_in_modal_with(acc_attrs)
    expect(find("input[name='name']",
                visible: false).value).to eq(acc_attrs[:name])
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
