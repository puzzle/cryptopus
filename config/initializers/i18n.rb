# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

# config/initializers/i18n.rb

module I18n

  def self.name_for_locale(locale)
    I18n.backend.translate(locale, "i18n.language.name")
  rescue I18n::MissingTranslationData
    locale.to_s
  end

  def self.available_locales
    ['en', 'de', 'fr', 'zh', 'ch_be']
  end

end

# E.g.:
#   I18n.name_for_locale(:en)  # => "English"
