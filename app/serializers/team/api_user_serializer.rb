class Team::ApiUserSerializer < ApplicationSerializer

  attributes :id, :username, :valid_for, :enabled?

  delegate :id,
           :username,
           :valid_for,
           :enabled?,
           to: :object
end
