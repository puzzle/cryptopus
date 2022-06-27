# frozen_string_literal: true

# == Schema Information
#
# Table name: teammembers
#
#  id         :integer          not null, primary key
#  info       :string

class FallbackInfo < ApplicationRecord
  self.table_name = :fallback_info
end
