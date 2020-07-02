# frozen_string_literal: true

require 'rails_helper'

describe LegacyRoutes::UrlHandler do
  include IntegrationHelpers::DefaultHelper

  # /de/teams/1/folders/1 -> /teams/1/folders/1/
  it 'redirects to team show without folders in url' do
    team1 = teams(:team1)
    folder1 = folders(:folder1)

    legacy_account_url = "/de/teams/#{team1.id}/folders/#{folder1.id}"
    login_as('bob')

    get legacy_account_url

    assert_redirected_to team_folder_path(team1, folder1)
  end

  # /de/teams/1/folders/1/accounts -> /teams/1/folders/1/
  it 'redirects to accounts url with accounts in legacy url' do
    team1 = teams(:team1)
    folder1 = folders(:folder1)

    legacy_account_url = "/de/teams/#{team1.id}/folders/#{folder1.id}/accounts"
    login_as('bob')

    get legacy_account_url

    assert_redirected_to team_folder_path(teams(:team1), folders(:folder1))
  end

  # /de/teams/1/groups -> /teams/1/
  it 'redirects to folders with groups in url' do
    team1 = teams(:team1)

    legacy_team_url = "/de/teams/#{team1.id}/groups"
    login_as('bob')

    get legacy_team_url

    assert_redirected_to teams_path(teams(:team1).id)
  end

  # /de/teams/1/folders/1/ -> /teams/1/folders/1/
  it 'redirects to teams url with locale in url' do
    team1 = teams(:team1)
    folder1 = folders(:folder1)


    legacy_team_url = "/de/teams/#{team1.id}/folders/#{folder1.id}"
    redirect_url = team_folder_path(team1, folder1)
    login_as('bob')

    get legacy_team_url
    assert_redirected_to redirect_url
  end

  # /de/login/login -> /login/login
  it 'redirects to login url without locale' do
    get '/de/login/login'

    assert_redirected_to session_new_path
  end

  # /de/teams/1/folders/1/accounts -> /accounts
  it 'redirects to account url without locale' do
    team1 = teams(:team1)
    folder1 = folders(:folder1)

    legacy_accounts_url = "/de/teams/#{team1.id}/folders/#{folder1.id}/accounts"
    login_as('bob')

    get legacy_accounts_url

    assert_redirected_to team_folder_path(team1, folder1)
  end

  # /de/profile -> /profile
  it 'redirects to profile url without locale' do
    login_as('bob')
    get '/de/profile'

    assert_redirected_to profile_path
  end

  # /de/search?q= -> /teams?q=
  it 'redirects to search url without locale' do
    login_as('bob')
    get '/de/search?q='

    assert_redirected_to '/teams'
  end

  # /de/admin/settings/index -> /admin/settings/index
  it 'redirects to admin settings url without locale' do
    login_as('bob')
    get '/de/admin/settings/index'

    assert_redirected_to admin_settings_path
  end

  # /de/teams/1/folders/1/accounts -> RoutingError
  it 'raises RoutingError when user accesses non valid route' do
    team1 = teams(:team1)
    folder1 = folders(:folder1)

    invalid_account_url = "/teams/#{team1.id}/folders/#{folder1.id}/gibberish"
    login_as('bob')

    expect { get invalid_account_url }.to raise_error(ActionController::RoutingError)
  end

  # /ch_vs/teams/1/folders/1/accounts -> RoutingError
  it 'raises RoutingError when user accesses non valid route with unknown locale' do
    team1 = teams(:team1)
    folder1 = folders(:folder1)

    invalid_account_url = "/ch_vs/teams/#{team1.id}/folders/#{folder1.id}/gibberish"
    login_as('bob')

    expect { get invalid_account_url }.to raise_error(ActionController::RoutingError)
  end

  # /en/login/login -> /
  it 'redirects to to root path for old login path' do
    get '/en/login/login'

    assert_redirected_to session_new_path

    login_as('bob')

    assert_redirected_to root_path
  end

  # /teams/1/groups/1 -> /teams/1/folders/1
  it 'redirects group to folder' do
    login_as('bob')

    team1 = teams(:team1)
    folder1 = folders(:folder1)
    legacy_folder_url = "/teams/#{team1.id}/groups/#{folder1.id}"

    get legacy_folder_url

    assert_redirected_to team_folder_path(team1, folder1)
  end

  context 'if not logged in' do
    it 'should set locale to default and redirect to login' do
      team1 = teams(:team1)
      folder1 = folders(:folder1)

      invalid_account_url = team_folder_path(team1, folder1)
      get invalid_account_url

      expect(I18n.locale).to eq(:en)
      assert_redirected_to session_new_path
    end
  end

  context 'frontend files' do
    # /teams -> /teams
    it 'gets delivered on frontend route' do
      teams_url = '/teams'
      login_as('bob')

      get teams_url

      assert_template 'frontend/index'
    end

    # /ch_vs/teams -> /teams
    it 'gets delivered on frontend route with unknown locale' do

      teams_url = '/ch_vs/teams'
      login_as('bob')

      expect { get teams_url }.to raise_error(ActionController::RoutingError)
    end

    # /de/teams/1/folders/1/accounts/1/ -> /accounts/1/
    it 'gets delivered when redirecting to team1 url without locale' do
      team1 = teams(:team1)
      folder1 = folders(:folder1)
      account1 = accounts(:account1)

      legacy_account_url = "/de/teams/#{team1.id}/folders/" \
        "#{folder1.id}/accounts/#{account1.id}/"
      login_as('bob')

      get legacy_account_url

      assert_redirected_to "/accounts/#{account1.id}"
      follow_redirect!
      assert_template 'frontend/index'
    end

    # /de/teams -> /teams
    it 'gets delivered when redirecting to teams url with german locale' do
      login_as('bob')

      get '/de/teams'

      assert_redirected_to '/teams'
      follow_redirect!
      assert_template 'frontend/index'
    end

    # /en/teams -> /teams
    it 'gets delivered when redirecting to teams url with english locale' do
      login_as('bob')

      get '/en/teams'

      assert_redirected_to '/teams'
      follow_redirect!
      assert_template 'frontend/index'
    end

    # /fr/teams -> /teams
    it 'gets delivered when redirecting to teams url with french locale' do
      login_as('bob')

      get '/fr/teams'
      assert_redirected_to '/teams'
      follow_redirect!
      assert_template 'frontend/index'
    end
  end

  private

  def team_folder_path(team, folder)
    "/teams/#{team.id}/folders/#{folder.id}"
  end

  def teams_path(team_id = nil)
    return '/teams' if team_id.nil?

    "/teams/#{team_id}"
  end
end
