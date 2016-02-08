# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

module TeammembersHelper
  def teammember_entry(teammember)
    content_tag(:li) do
      teammember_icon(teammember) +
      teammember.user.label +
      delete_icon(teammember)
    end
  end

  def teammember_icon(teammember)
    if teammember.user.admin? || teammember.user.root?
      image_tag('flag.svg')
    else
      image_tag('user.svg')
    end
  end

  def delete_icon(teammember)
    if can_destroy_teammember?(teammember)
      link_to_destroy [@team, teammember], teammember
    end
  end

  def teammember_root_entry
    return if @team.noroot
    content_tag(:li) do
      image_tag('penguin.svg') +
      'Root'
    end
  end

  def can_destroy_teammember?(teammember)
    return false if teammember.user.root?
    @team.private? || !teammember.user.admin?
  end
end
