#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

module PasswordStrengthHelper

  def password_complexity(username, password)
    strength = PasswordStrength.test(username, password).status
    return if strength == :invalid

    filename = "#{strength}.png"
    text = t "password_strength.#{strength}"

    content = [image_tag(filename, id: 'password_strength')]
    content += [content_tag(:div, text)]
    safe_join(content)
  end
end
