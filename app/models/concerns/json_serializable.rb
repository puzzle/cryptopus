# frozen_string_literal: true

module JsonSerializable
  extend ActiveSupport::Concern

  class_methods do
    def load(json)
      return new if json.blank?

      new(JSON.parse(json, symbolize_names: true))
    end

    def dump(obj)
      if obj.respond_to? :to_json
        obj.to_json
      else
        raise StandardError, "Expected #{self}, got #{obj.class}"
      end
    end
  end
end
