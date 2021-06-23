# frozen_string_literal: true

class Api::Admin::SettingsController < ApiController
  self.permitted_attrs = [value: []]
  self.custom_model_class = Setting
end
