# frozen_string_literal: true

require 'spec_helper'

describe RedirectedRoutes::UrlHandler do

  it 'return redirect url without locale when locale in url' do
    url = '/de/teams/1/groups/1'
    url_without_locale = '/teams/1/folders/1'

    redirect_url = RedirectedRoutes::UrlHandler.new(url).redirect_to

    expect(redirect_url).to eq url_without_locale
  end

  it 'return redirect url without accounts when accounts in url' do
    url = '/de/teams/1/groups/1/accounts'
    url_without_accounts = '/teams/1/folders/1'

    redirect_url = RedirectedRoutes::UrlHandler.new(url).redirect_to

    expect(redirect_url).to eq url_without_accounts
  end

  it 'return redirect url without accounts when accounts in url' do
    url = '/de/teams/1/groups/1/accounts/1'
    url_without_accounts = '/accounts/1'

    redirect_url = RedirectedRoutes::UrlHandler.new(url).redirect_to

    expect(redirect_url).to eq url_without_accounts
  end

  it 'return redirect url without teams when teams in url' do
    url = '/de/teams/1/groups'
    url_without_teams = '/teams/1'

    redirect_url = RedirectedRoutes::UrlHandler.new(url).redirect_to

    expect(redirect_url).to eq url_without_teams
  end

  it 'returns the root url for legacy login route' do
    legacy_login_url = '/login/login'
    root_url = '/'

    redirect_url = RedirectedRoutes::UrlHandler.new(legacy_login_url).redirect_to

    expect(redirect_url).to eq root_url
  end
end
