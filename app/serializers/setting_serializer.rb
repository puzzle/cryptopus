# frozen_string_literal: true

# == Schema Information
#
# Table name: settings
#
#  id    :integer          not null, primary key
#  key   :string           not null
#  value :string
#  type  :string           not null
#

class SettingSerializer < ApplicationSerializer
    attributes :id, :key, :value
end
