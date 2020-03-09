# frozen_string_literal: true

Rails.application.routes.draw do
  get '(:locale)/*route', to: 'legacy_routes#redirect'
end
