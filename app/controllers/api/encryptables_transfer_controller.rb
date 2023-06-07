# frozen_string_literal: true

class Api::EncryptablesTransferController < ApiController

  self.permitted_attrs = [:name, :description, :receiver_id, :file]

  def create
    if params[:file].present?
      prepare_encryptable_file
    else
      prepare_encryptable_credential
    end
    authorize entry
    transfer_encryptable

    render json: messages
  end

  private

  def transfer_encryptable
    @encryptable = EncryptableTransfer.new.transfer(
      entry, User::Human.find(receiver_id), current_user
    )

    add_info('flashes.encryptable_transfer.file.transferred')
  end

  def prepare_encryptable_credential
    shared_encryptable = current_user.encryptables.find(params['encryptable_id'])

    shared_encryptable.decrypt(decrypted_team_password(shared_encryptable.team))

    instance_variable_set(:"@#{ivar_name}", shared_encryptable.dup)
  end

  def prepare_encryptable_file
    filename = params[:file].original_filename

    inbox_folder_receiver = receiver.inbox_folder

    file = new_file(inbox_folder_receiver, params[:description], filename)
    file.content_type = params[:file].content_type
    file.cleartext_file = params[:file].read

    instance_variable_set(:"@#{ivar_name}", file)
  end

  def new_file(inbox_folder_receiver, description, name)
    Encryptable::File.new(folder: inbox_folder_receiver,
                          description: description,
                          name: name)
  end

  def model_class
    params[:file].present? ? Encryptable::File : Encryptable::Credentials
  end

  def model_params
    params.permit(permitted_attrs)
  end

  def receiver_id
    params['receiver_id']
  end

  def receiver
    receiver_id && User::Human.find(receiver_id)
  end
end
