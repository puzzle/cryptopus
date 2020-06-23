# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

include Rails.application.routes.url_helpers

class LegacyRoutes::UrlHandler

  FRONTEND_PATHS = {
    teams_index: /(\/teams)$/,
    teams_new: /(\/teams\/new)$/,
    teams_edit: /(\/teams\/\d+\/edit)$/,
    teams_configure: /(\/teams\/\d+\/configure)$/,
    folders_new: /(\/teams\/folders\/new)$/,
    folders_edit: /(\/teams\/\d+\/folders\/\d+\/edit)$/,
    accounts_new: /(\/accounts\/new)$/,
    accounts_edit: /(\/accounts\/\d+\/edit)$/,
    file_entries: /(\/accounts\/\d+\/file_entries)$/,
    file_entries_new: /(\/accounts\/\d+\/file_entries\/new)$/
  }.freeze

  FRONTEND_PATHS = {
    teams_index: /(\/teams)$/,
    teams_new: /(\/teams\/new)$/,
    teams_edit: /(\/teams\/\d+\/edit)$/,
    teams_configure: /(\/teams\/\d+\/configure)$/,
    folders_new: /(\/teams\/folders\/new)$/,
    folders_edit: /(\/teams\/\d+\/folders\/\d+\/edit)$/,
    accounts_new: /(\/accounts\/new)$/,
    accounts_edit: /(\/accounts\/\d+\/edit)$/,
    file_entries: /(\/accounts\/\d+\/file_entries)$/,
    file_entries_new: /(\/accounts\/\d+\/file_entries\/new)$/
  }.freeze

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
    rename_group_to_folder
    @url
  end

  def frontend_path?
    FRONTEND_PATHS.values.any? do |p|
      @url.match(p)
    end
  end

  private

  def new_url
    LEGACY_PATHS.each do |model, path|
      if @url.match(path)
        @url = send("new_#{model}_path")
        break
      end
    end
  end

  def remove_locale
    @url = @url.dup.remove(/#{LOCALES_REGEX}/)
  end

  def rename_group_to_folder
    @url = @url.gsub(/(group)/, 'folder')
  end

  def legacy_locales_path?
    @url.match(/(#{LOCALES_REGEX})\//)
  end

  def new_accounts_path
    "/accounts/#{@url.split('/').last}"
  end

  def new_groups_path
    "/teams/#{@url.split('/').third}/folders/#{@url.split('/').second_to_last}"
  end

  def new_teams_path
    "/teams/#{@url.split('/').second_to_last}"
  end

  def new_login_path
    root_path
  end
end
