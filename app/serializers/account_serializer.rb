# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
#
#  id          :integer          not null, primary key
#  accountname :string(70)       default(""), not null
#  group_id    :integer          default(0), not null
#  description :text
#  username    :binary
#  password    :binary
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  tag         :string
#

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class AccountSerializer < ApplicationSerializer
  attributes :id, :accountname, :group, :group_name, :group_id, :team_name, :team_id,
             :cleartext_password, :cleartext_username
  # Note: Ember uses this serializer and expects group to return the id.
  # Thus, next to group_id, group returns the id aswell.

  def cleartext_password
    object.cleartext_password
  end

  def cleartext_username
    object.cleartext_username
  end

  def group
    object.group.id
  end

  def group_id
    object.group.id
  end

  def group_name
    object.group.name
  end

  def team_id
    object.group.team.id
  end

  def team_name
    object.group.team.name
  end

end
