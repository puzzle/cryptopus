# frozen_string_literal: true

module Authentication
  class OicdPolicy < ApplicationPolicy

    def create?
      AuthConfig.oidc_enabled?
    end

  end
end
