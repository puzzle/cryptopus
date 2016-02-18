# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

# require_dependency "search"

class Group < ActiveRecord::Base
  belongs_to :team
  has_many :accounts, -> { order :accountname }, dependent: :destroy

  validates :name, presence: true

  def label
    name
  end
end
