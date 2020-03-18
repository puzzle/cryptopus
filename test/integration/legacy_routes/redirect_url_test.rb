# frozen_string_literal: true

class LegacyRoutes::RedirectUrlTest < ActionDispatch::IntegrationTest

  test 'return redirect url without locale when locale in url' do
    url = '/de/teams/1/groups/1'
    url_without_locale = '/teams/1/groups/1'

    redirect_url = LegacyRoutes::RedirectUrl.new(url).redirect_to

    assert_equal(redirect_url, url_without_locale)
  end

  test 'return redirect url without groups when groups in url' do
    url = '/de/teams/1/groups/1/accounts'
    url_without_groups = '/teams/1/groups/1'

    redirect_url = LegacyRoutes::RedirectUrl.new(url).redirect_to

    assert_equal(redirect_url, url_without_groups)
  end

  test 'return redirect url without accounts when accounts in url' do
    url = '/de/teams/1/groups/1/accounts/1'
    url_without_accounts = '/accounts/1'

    redirect_url = LegacyRoutes::RedirectUrl.new(url).redirect_to

    assert_equal(redirect_url, url_without_accounts)
  end

  test 'return redirect url without teams when teams in url' do
    url = '/de/teams/1/groups'
    url_without_teams = '/teams/1'

    redirect_url = LegacyRoutes::RedirectUrl.new(url).redirect_to

    assert_equal(redirect_url, url_without_teams)
  end
end
