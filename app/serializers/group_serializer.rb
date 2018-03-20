# encoding: utf-8
# == Schema Information
#
# Table name: groups
#
#  id          :integer          not null, primary key
#  name        :string(40)       default(""), not null
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  team_id     :integer          default(0), not null
#

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class GroupSerializer < ActiveModel::Serializer
  attributes :id, :name, :team, :team_id

  def team
    object.team.name
  end

  def team_id
    object.team.id
  end
end
