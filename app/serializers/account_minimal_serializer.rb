class AccountApiSerializer < ApplicationSerializer
  attributes :id, :name, :description

  belongs_to :folder
end
