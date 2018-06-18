#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

module Password
  class Strength

    include ActionView::Helpers::OutputSafetyHelper
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::AssetTagHelper
    include ActionView::Context

    delegate :t, to: I18n

    def initialize(username, password)
      @username = username
      @password = password
    end

    def password_complexity
      strength = PasswordStrength.test(@username, @password)
      if strength.status == :weak || strength.status == :invalid
        filename = 'weak.png'
        text = t 'password_strength.weak'
      elsif strength.status == :good
        filename = 'good.png'
        text = t 'password_strength.good'
      elsif strength.status == :strong
        filename = 'strong.png'
        text = t 'password_strength.strong'
      end
      content = [image_tag(filename, id: 'password_strength')]
      content += [content_tag(:div, text)]
      safe_join(content)
    end
  end
end
