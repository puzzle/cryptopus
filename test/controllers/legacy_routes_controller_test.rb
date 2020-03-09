# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class LegacyRoutesControllerTest < ActiveSupport::TestCase

  url_without_locale = "http://localhost:3000/teams/9/groups"

  test 'no locale in url' do
    url = 'http://localhost:3000/teams/9/groups'

    redirect_url = legacy_locale.redirect_url(url)

    assert_equal(redirect_url, url_without_locale)
  end

  test 'locale in url' do
    url = 'http://localhost:3000/de/teams/9/groups'

    redirect_url = legacy_locale.redirect_url(url)

    assert_equal(redirect_url, url_without_locale)
  end

  test 'locale occurrence in uppercase' do
    url = 'http://localhost:3000/De/teams/9/groups'

    redirect_url = legacy_locale.redirect_url(url)

    assert_equal(redirect_url, url_without_locale)
  end

  private

  def legacy_locale
    LegacyRoutes::Locale.new
  end
end
