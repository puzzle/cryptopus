
require 'spec_helper'

describe 'log', type: :system, js: true do
  include SystemHelpers


it 'as admin is there everything avaible' do
    login_as_root
    visit('/log')
    expect(page).to have_text('Personal activity log') 
    expect(page).not_to have_text('button id="ember4608"')
    expect(page).to have_text('Action')
    expect(page).to have_text('Date')
    expect(page).to have_text('Change')
#require 'pry'; binding.pry
  end
it 'is the Log correct' do 
    login_as_root
    visit('/log')
#action 
    expect(page).to have_text('these are not implemented yet') 
    #Date
    expect(page).not_to have_text('this neither')
    #Change
    expect(page).to have_text('nope just example')
    logout
  end

it 'as user is there everything avaible' do
      login_as_user(:tux)
    visit('/log')

    expect(page).to have_text('Personal activity log') 
    expect(page).to have_text('Personal activity log') 
    expect(page).to have_text('button id="ember4608"')
    expect(page).to have_text('Action')
    expect(page).to have_text('Date')
    expect(page).to have_text('Change')    
  end
it 'is the Log correct' do 
#require 'pry'; binding.pry
      login_as_user(:tux)
    visit('/log')
	#action 
    expect(page).to have_text('these are not implemented yet') 
    #Date
    expect(page).to have_text('this neither')
    #Change
    expect(page).to have_text('nope just example')
    logout
  end
end
