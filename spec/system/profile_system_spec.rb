# frozen_string_literal: true

require 'spec_helper'

describe 'ProfilePage', type: :system, js: true do
  include SystemHelpers


  it 'sets first api user as default ccli user' do
    login_as_user(:admin)
    visit('/profile')

    expect(page).to have_text('Profile')
    click_link('Api Users')

    expect(page).to have_text('New')

    # create two new api_user
    click_button('New')
    click_button('New')

    expect(page).to have_css('table')
    within 'table' do
      table_rows = all('tr')

      # expect two but indeed three because header counts as well
      expect(table_rows.length).to eq(3)

      first_table_row = table_rows[1]
      last_table_row = table_rows.last

      first_ccli_default_user_cell = first_table_row.all('td')[6]
      last_ccli_default_user_cell = last_table_row.all('td')[6]


      checked_toggle = 'span.x-toggle-container.medium.x-toggle-container-checked.ember-view'

      within first_ccli_default_user_cell do
        find('div.x-toggle-component').click
        expect(page).to have_css(checked_toggle)
      end

      within last_ccli_default_user_cell do
        expect(page).not_to have_css(checked_toggle)

        # toggle the second row toggle to check that the first row toggle gets deselected
        find('div.x-toggle-component').click

        # proof that it has been selected
        expect(page).to have_css(checked_toggle)
      end

      # proof that it has been deselected
      within first_ccli_default_user_cell do
        expect(page).not_to have_css(checked_toggle)
      end

      # delete created api users
      within first_table_row do
        find('span[role="button"]').click
        click_button('Delete')
      end

      within last_table_row do
        find('span[role="button"]').click
        click_button('Delete')
      end
    end

    # proof that only the table header remains
    expect(page).to have_text('No api users')
  end

  it 'doesnt show ccli default user row within api users table as conf_admin' do
    login_as_user(:tux)
    visit('/profile')

    expect(page).to have_text('Profile')
    click_link('Api Users')

    expect(page).to have_text('New')

    # create api user
    click_button('New')

    expect(page).to have_css('table')
    within 'table' do
      table_rows = all('tr')

      # expect one but indeed two because header counts as well
      expect(table_rows.length).to eq(2)

      first_table_row = table_rows.first
      last_table_row = table_rows.last

      expect(first_table_row).not_to have_text('Ccli default user')

      within last_table_row do
        expect(all('td').count).to eq(7)
      end
    end
  end
end
