# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

include Rails.application.routes.url_helpers

class LegacyRoutes::RedirectUrl
  LOCALES_REGEX = I18n.available_locales.map do |locale|
    "\/#{locale}|"
  end.join('').chop.freeze

  def initialize(url)
    @url = url
  end

  def redirect_to
    remove_locale
    new_url
  end

  def new_url
    case @url
    when legacy_accounts_path?
      account_path(@url.split('/').last)
    when legacy_groups_path?
      team_group_path(@url.split('/').third, @url.split('/').second_to_last)
    when legacy_teams_path?
      team_path(@url.split('/').second_to_last)
    else
      @url
    end
  end

  def remove_locale
    @url = @url.dup.remove(/#{LOCALES_REGEX}/)
  end

  def legacy_locales_path?
    /#{LOCALES_REGEX}/
  end

  def legacy_groups_path?
    /(accounts)$/
  end

  def legacy_teams_path?
    /(groups)$/
  end

  def legacy_accounts_path?
    /(accounts)\/\d+$/
  end
end
