# frozen_string_literal: true

class Team::ApiUserSerializer < ApplicationSerializer

  attributes :id, :username, :description, :enabled

  delegate :id,
           :username,
           :description,
           to: :object

  def enabled
    object.enabled?
  end
end
