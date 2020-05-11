# frozen_string_literal: true

# == Schema Information
#
# Table name: teammembers
#
#  id         :integer          not null, primary key
#  team_id    :integer          default(0), not null
#  password   :binary           not null
#  user_id    :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#


# Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

class TeammemberSerializer < ActiveModel::Serializer
  attributes :id, :user, :user_id, :label, :deletable, :admin

  def user
    user_object.id
  end

  def user_id
    user_object.id
  end

  def deletable
    return false if last_teammember?
    return true if private_team?

    !user_object.admin?
  end

  def admin
    return false if private_team?

    user_object.admin?
  end

  private

  def user_object
    object.user
  end

  def last_teammember?
    object.team.last_teammember?(user_object)
  end

  def private_team?
    object.team.private?
  end
end
