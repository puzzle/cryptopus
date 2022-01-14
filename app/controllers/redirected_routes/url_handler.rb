# frozen_string_literal: true

include Rails.application.routes.url_helpers

class RedirectedRoutes::UrlHandler

  FRONTEND_PATHS = {
    teams_index: /(^\/teams)$/,
    teams_show: /(^\/teams\/\d+)$/,
    folder_show: /(^\/teams\/\d+\/folders\/\d+)$/,
    encryptables_show: /(^\/encryptables\/\d+)$/,
    profile_index: /(^\/profile)$/,
    admin_users_index: /(^\/admin\/users)$/,
    admin_settings: /(^\/admin\/settings)$/,
    dashboard: /(^\/dashboard)$/
  }.freeze

  LEGACY_PATHS = {
    teams: /(groups)$/,
    groups: /(accounts)$/,
    accounts: /(accounts)\/\d+$/,
    login: /(\/login)$/,
    search: /(\/search)/
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
    @url.match?(/(#{LOCALES_REGEX})\//)
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

  def new_search_path
    if @url.include?('?q=') && @url.split('?q=').length > 1
      "/teams?#{@url.split('?').last}"
    else
      '/teams'
    end
  end

end
