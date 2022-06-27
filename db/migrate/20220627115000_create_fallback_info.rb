# frozen_string_literal: true

class CreateFallbackInfo < ActiveRecord::Migration[7.0]
  def change
    create_table :fallback_info do |t|
      t.column :info, :string
    end
  end
end
