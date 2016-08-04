# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class AccountSerializer < ApplicationSerializer
  attributes :id, :accountname, :group_id, :group, :team, :team_id, :cleartext_password, :cleartext_username
  
  def cleartext_password
    object.cleartext_password
  end
  
  def cleartext_username
    object.cleartext_username
  end

  def group
    object.group.name
  end

  def team
    object.group.team.name
  end

  def team_id
    object.group.team.id
  end
end
