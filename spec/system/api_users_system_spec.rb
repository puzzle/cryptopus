# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'

describe 'ApiUsers', type: :system, js: true do
  include SystemHelpers

  before(:each) do
    login_as_user('bob')
  end

  it 'should create edit and delete an api_user' do
    visit(profile_path)

    click_link 'Api Users'

    click_button 'New'
    click_button 'New'

    within('#api_users_table_body') do
      expect(page).to have_xpath(".//tr", :count => 2)

      #check if table contains api user with username in name
      expect(page.text).to match(/^bob/)
    end

    #remove first api user
    first('img#remove-user').click
    click_button 'Yes'

    within('#api_users_table_body') do
      expect(page).to have_xpath(".//tr", :count => 1)
    end

    within('div.api-user-description') do
      find(:xpath, "//i").click
    end

    fill_in 'descriptionInput', with: ('description from api_user')

    click_link 'Api Users'

    within('#api_users_table_body') do
      #check if table contains api user with updated description
      expect(page.text).to match('description from api_user')

      #check if possible to lock api_user
      expect(find('div#active-api-user.toggle-button').click)
      expect(find('div#active-api-user.toggle-button-selected'))

      # renew user to validate that valid until has values
      expect(find('img#renew-user.action-icons').click)
      expect(find("div#valid_until").text) != ''

      #delete last available api_user
      expect(find("img#remove-user.action-icons").click)
    end
    click_button 'Yes'
    expect(page.text).to match('No api users')

  end
end
