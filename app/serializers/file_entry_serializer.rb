# frozen_string_literal: true

# == Schema Information
#
# Table name: file_entries
#
#  id           :integer          not null, primary key
#  account_id   :integer          default(0), not null
#  description  :text
#  file         :binary
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  filename     :text             not null
#  content_type :text             not null
#

class FileEntrySerializer < ApplicationSerializer
  attributes :id, :filename, :description

  belongs_to :encryptable
end
