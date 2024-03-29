# frozen_string_literal: true

require 'spec_helper'

describe 'NavBar', type: :system, js: true do
  include SystemHelpers

  it 'shows admin button as admin' do
    login_as_user(:admin)

    within(page.find('pzsh-menu')) do
      expect(page.body).to have_text('Admin', count: 2)
    end

    logout
  end

  it 'shows admin button as tux' do
    login_as_user(:tux)

    within(page.find('pzsh-menu')) do
      expect(page.body).to have_text('Admin', count: 1)
    end

    logout
  end

  it 'shows admin button as root' do
    login_as_root

    within(page.find('pzsh-menu')) do
      expect(page.body).to have_text('Admin', count: 1)
    end

    logout
  end

  it 'does not show admin button as bob' do
    login_as_user(:bob)

    within(page.find('pzsh-menu')) do
      expect(page.body).to_not have_text('Admin')
    end

    logout
  end
end
