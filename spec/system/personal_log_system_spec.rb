# frozen_string_literal: true

require 'spec_helper'
require 'pry'

describe 'personal log', type: :system, js: true do
  include SystemHelpers

  it 'contains personal_logs table with right logs in page' do
    create_logs
    login_as_user(:bob)
    visit('/personal_logs')

    expect(page).to have_text('Personal activity log')
    expect(page).to have_css('table')

    within 'table' do
      table_rows = all('tr')

      expect(table_rows.length).to eq(3)
      top_row = table_rows[1]

      within top_row do
        expect(page).to have_text('viewed')
        expect(page).to have_text(encryptables(:credentials2).name)
      end
    end

    logout
    login_as_user(:alice)
    visit('/personal_logs')

    expect(page).to have_text('Personal activity log')
    expect(page).to have_css('table')

    within 'table' do
      table_rows = all('tr')

      expect(table_rows.length).to eq(2)
      top_row = table_rows[1]

      within top_row do
        expect(page).to have_text('viewed')
        expect(page).to have_text(encryptables(:credentials1).name)
      end
    end
  end

  private

  def create_logs
    login_as_user(:bob)
    visit("/encryptables/#{encryptables(:credentials1).id}")
    visit("/encryptables/#{encryptables(:credentials2).id}")
    logout
    login_as_user(:alice)
    visit("/encryptables/#{encryptables(:credentials1).id}")
    logout
  end
end
