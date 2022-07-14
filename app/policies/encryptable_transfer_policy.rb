# frozen_string_literal: true

class EncryptableTransferPolicy < TeamDependantPolicy

   def create?
     require 'pry'; binding.pry unless $pstop
     true
     #current_user.present?
   end

end
