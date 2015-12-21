# $Id$

# Copyright (c) 2007 Puzzle ITC GmbH. All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

class Teammember < ActiveRecord::Base
  delegate :label, to: :user
  belongs_to :team
  belongs_to :user
  before_destroy :protect_if_last_teammember

  scope :admins, -> { joins(:user).where(users: { admin: true}) }
  scope :non_admins, -> { joins(:user).where(users: { admin: false}) }

  private
  def protect_if_last_teammember
    if team.teammembers.count == 1
      errors.add(:base, 'Cannot remove last teammember')
      false
    end
  end

end
