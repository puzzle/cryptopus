# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class LegacyRoutes::Url

  GROUPS_STRING = 'groups'
  ACCOUNTS_STRING = 'accounts'

  LOCALES_REGEX = I18n.available_locales.map do |locale|
    "\/#{locale}|"
  end.join('').chop.freeze

  def redirect_url(url)
    url.downcase.remove(/#{LOCALES_REGEX}/)

    last_element = url.downcase.split('/').last

    if last_element == GROUPS_STRING || last_element ==  ACCOUNTS_STRING
      url.downcase.remove(last_element)
    else
      url
    end
  end
end
