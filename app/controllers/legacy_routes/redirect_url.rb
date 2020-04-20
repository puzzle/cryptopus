# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

include Rails.application.routes.url_helpers

class LegacyRoutes::RedirectUrl

  LEGACY_PATHS = {
    teams: /(groups)$/,
    groups: /(accounts)$/,
    accounts: /(accounts)\/\d+$/,
    login: /(\/login)$/
  }.freeze

  LOCALES_REGEX = I18n.available_locales.map do |locale|
    "\/#{locale}|"
  end.join('').chop.freeze

  def initialize(url)
    @url = url
  end

  def redirect_to
    remove_locale if legacy_locales_path?
    new_url
  end

  def new_url
    LEGACY_PATHS.each do |model, path|
      return send("new_#{model}_path") if @url.match(path)
    end

    @url
  end

  def remove_locale
    @url = @url.dup.remove(/#{LOCALES_REGEX}/)
  end

  def legacy_locales_path?
    /#{LOCALES_REGEX}/
  end

  def new_accounts_path
    account_path(@url.split('/').last)
  end

  def new_groups_path
    team_group_path(@url.split('/').third, @url.split('/').second_to_last)
  end

  def new_teams_path
    team_path(@url.split('/').second_to_last)
  end

  def new_login_path
    root_path
  end
end
