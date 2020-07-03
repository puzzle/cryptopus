# frozen_string_literal: true

Rails.application.routes.draw do
  get '(:locale)/*route', to: 'redirected_routes#redirect'
end
