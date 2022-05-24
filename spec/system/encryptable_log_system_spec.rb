# frozen_string_literal: true

require 'spec_helper'

describe 'encryptable log', type: :system, js: true do
  include SystemHelpers

  describe 'logs view access' do
    it 'contains credentials and logs table in page' do
      login_as_user(:bob)
      visit("/encryptables/#{encryptables(:credentials1).id}")
      expect(page).to have_text('Credentials')
      click_link('Logs')

      expect(page).to have_css('table')
      within 'table' do
        table_rows = all('tr')

        expect(table_rows.length).to eq(2)
        top_row = table_rows[1]

        within top_row do
          expect(page).to have_text('viewed')
          expect(page).to have_text('bob')
        end
      end
    end

    it 'contains log for update' do
      login_as_user(:bob)
      visit("/encryptables/#{encryptables(:credentials1).id}")
      edit_encryptable
      click_link('Logs')

      within 'table' do
        table_rows = all('tr')

        expect(table_rows.length).to eq(3)

        top_row = table_rows[1]

        within top_row do
          expect(page).to have_text('edited')
          expect(page).to have_text('bob')
        end
      end
    end
  end

  private

  def edit_encryptable
    find('#edit_account_button').click
    within('form.ember-view[role="form"]', visible: false) do
      find("input[name='cleartextUsername']", visible: false).set 'username2'
    end
    click_button('Save', visible: false)
  end
end
