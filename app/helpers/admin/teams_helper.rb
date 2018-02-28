#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

module Admin::TeamsHelper
  def number_of_groups
    @team.groups.count
  end

  def number_of_accounts
    accounts = 0
    @team.groups.each do |group|
      accounts += group.accounts.count
    end
    accounts
  end

  #def teammember_list
    #content_tag(:ul, '', class: 'members-list').html_safe
  #end

  #def members_button
    #link_to('Show', '', class: 'members-link', remote: true).html_safe
  #end
end
