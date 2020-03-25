# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class LegacyRoutesControllerTest < ActiveSupport::TestCase

  url_without_locale = "http://localhost:3000/teams"
  url_without_groups = "http://localhost:3000/teams/9/"
  url_without_accounts = "http://localhost:3000/teams/9/groups/9/"

  test 'no locale in url' do
    url = 'http://localhost:3000/teams'

    redirect_url = legacy_handler.redirect_url(url)

    assert_equal(redirect_url, url_without_locale)
  end

  test 'locale in url' do
    url = 'http://localhost:3000/teams'

    redirect_url = legacy_handler.redirect_url(url)

    assert_equal(redirect_url, url_without_locale)
  end

  test 'groups in url' do
    url = 'http://localhost:3000/teams/9/groups'

    redirect_url = legacy_handler.redirect_url(url)

    assert_equal(redirect_url, url_without_groups)
  end

  test 'no groups in url' do
    url = 'http://localhost:3000/teams/9/'

    redirect_url = legacy_handler.redirect_url(url)

    assert_equal(redirect_url, url_without_groups)
  end

  test 'accounts in url' do
    url = 'http://localhost:3000/teams/9/groups/9/accounts'

    redirect_url = legacy_handler.redirect_url(url)

    assert_equal(redirect_url, url_without_accounts)
  end

  test 'no accounts in url' do
    url = 'http://localhost:3000/teams/9/groups/9/'

    redirect_url = legacy_handler.redirect_url(url)

    assert_equal(redirect_url, url_without_accounts)
  end

  private

  def legacy_handler
    LegacyRoutes::Handler.new
  end
end
