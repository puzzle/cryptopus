# frozen_string_literal: true

class Api::EncryptablesTransferController < ApiController

  self.permitted_attrs = [:name, :description, :receiver_id, :file]

  def create
    prepare_encryptable_file
    authorize entry
    transfer_file

    render json: messages
  end

  private

  def transfer_file
    @encryptable = EncryptableTransfer.new.transfer(entry, User::Human.find(receiver_id), current_user)

    add_info('flashes.encryptable_transfer.file.transferred')
  end

  def prepare_encryptable_file
    filename = params[:file].original_filename

    inbox_folder_receiver = receiver.inbox_folder

    file = new_file(nil, inbox_folder_receiver, params[:description], filename)
    file.content_type = params[:file].content_type
    file.cleartext_file = params[:file].read

    instance_variable_set(:"@#{ivar_name}", file)
  end

  def new_file(parent_encryptable, inbox_folder_receiver, description, name)
    Encryptable::File.new(encryptable_credential: parent_encryptable,
                          folder: inbox_folder_receiver,
                          description: description,
                          name: name)
  end

  def model_class
    Encryptable::File
  end

  def model_params
    params.permit(permitted_attrs)
  end

  def receiver_id
    params.dig('receiver_id')
  end

  def receiver
    return nil if receiver_id.nil?

    User::Human.find(receiver_id)
  end
end
