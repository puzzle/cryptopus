# frozen_string_literal: true

class Version < PaperTrail::Version
  belongs_to :user, class_name: 'User'
  belongs_to :encryptable, class_name: 'Encryptable'
end
