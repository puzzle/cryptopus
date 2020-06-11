# frozen_string_literal: true

# == Schema Information
#
# Table name: fileentries
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

require 'rails_helper'

describe FileEntriesController do
  include ControllerHelpers

end
