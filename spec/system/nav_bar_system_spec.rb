# frozen_string_literal: true

require 'spec_helper'

describe 'NavBar', type: :system, js: true do
  include SystemHelpers

  it 'shows admin button as admin' do
    login_as_user(:admin)
    visit('/')

    within(page.find('pzsh-menu')) do
      expect(page).to have_text('Admin').twice
    end

    logout
  end

  it 'shows admin button as tux' do
    login_as_user(:tux)

    within(page.find('pzsh-menu')) do
      expect(page).to have_text('Admin')
    end

    logout
  end

  it 'shows admin button as root' do
    login_as_root

    within(page.find('pzsh-menu')) do
      expect(page).to have_text('Admin')
    end

    logout
  end

  it 'does not show admin button as bob' do
    login_as_user(:bob)

    within(page.find('pzsh-menu')) do
      expect(page).to_not have_text('Admin')
    end

    logout
  end

  it 'does show Log Button for bob' do
    login_as_user(:bob)
    expect(page).to have_css('pzsh-menu')
    within('pzsh-menu') do
      all('pzsh-menu-dropdown').first.click
    end
    all('pzsh-menu-dropdown-item').first.click
    expect(page).to_not have_text('Settings')
    expect(page).to have_text('Profile')
    expect(page).to have_text('Log')
    expect(page).to have_text('Logout')

    logout
  end
  it 'Dropdowns show intended items for admin' do
    login_as_root
    expect(page).to have_css('pzsh-menu')
    within('pzsh-menu') do
      all('pzsh-menu-dropdown').first.click
    end
    all('pzsh-menu-dropdown-item').first.click
    expect(page).to have_text('Users')
    expect(page).to have_text('Settings')
    expect(page).to have_text('Profile')
    expect(page).to have_text('Log')
    expect(page).to have_text('Logout')

    logout
  end

  context 'Copy CCLI Login' do
    it 'shows Copy CCLI Login button' do
      login_as_user(:admin)
      dropdown_menus = all('pzsh-menu-dropdown', text: users(:admin).givenname).to_a
      dropdown_menus.second.click
      expect(find('pzsh-menu-dropdown-item', text: 'Copy CCLI Login')).to be_present
    end

    it 'copies ccli login command to clipboard' do
      login_as_user(:admin)
      dropdown_menus = all('pzsh-menu-dropdown', text: users(:admin).givenname).to_a
      dropdown_menus.second.click
      find('pzsh-menu-dropdown-item', text: 'Copy CCLI Login').click
      expect(find('span.message', text: 'CCLI Login command was copied!')).to be_present
    end
  end

end
