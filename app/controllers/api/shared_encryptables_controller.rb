class Api::SharedEncryptablesController < ApiController
  def create
    require 'pry'; binding.pry unless $pstop
    # SharedEncryptable.new(encryptable.id, current_user, user.id, 1234)
  end
end
