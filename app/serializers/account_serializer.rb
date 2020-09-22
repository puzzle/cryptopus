# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
#
#  id          :integer          not null, primary key
#  accountname :string(70)       default(""), not null
#  folder_id    :integer          default(0), not null
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
  attributes :id, :accountname, :description, :cleartext_password, :cleartext_username, :data

  belongs_to :folder

  def cleartext_username
    object.is_a?(Account::Credentials) ? object.cleartext_username : ''
  end

  def cleartext_password
    object.is_a?(Account::Credentials) ? object.cleartext_password : ''
  end

  def data
    object.is_a?(Account::OSESecret) ? object.data : ''
  end
end
