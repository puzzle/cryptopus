# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Teammember < ActiveRecord::Base
  delegate :label, to: :user
  belongs_to :team
  belongs_to :user
  before_destroy :protect_if_last_teammember

  scope :without_root, -> { joins(:user).where('users.uid != 0 OR users.uid is null') }

  private
  def protect_if_last_teammember
    if team.teammembers.count == 1
      errors.add(:base, 'Cannot remove last teammember')
      false
    end
  end

end
