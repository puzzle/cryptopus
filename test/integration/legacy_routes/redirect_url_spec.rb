# frozen_string_literal: true

require 'rails_helper'

describe LegacyRoutes::RedirectUrl do

  it 'return redirect url without locale when locale in url' do
    url = '/de/teams/1/groups/1/'
    url_without_locale = '/teams/1/groups/1/'

    redirect_url = LegacyRoutes::RedirectUrl.new(url).redirect_to

    expect(redirect_url).to eq url_without_locale
  end

  it 'return redirect url without groups when groups in url' do
    url = '/de/teams/1/groups/1/accounts'
    url_without_groups = '/teams/1/groups/1/'

    redirect_url = LegacyRoutes::RedirectUrl.new(url).redirect_to

    expect(redirect_url).to eq url_without_groups
  end

  it 'return redirect url without accounts when accounts in url' do
    url = '/de/teams/1/groups/1/accounts/1'
    url_without_accounts = '/accounts/1/'

    redirect_url = LegacyRoutes::RedirectUrl.new(url).redirect_to

    expect(redirect_url).to eq url_without_accounts
  end

  it 'return redirect url without teams when teams in url' do
    url = '/de/teams/1/groups'
    url_without_teams = '/teams/1/'

    redirect_url = LegacyRoutes::RedirectUrl.new(url).redirect_to

    expect(redirect_url).to eq url_without_teams
  end
end
