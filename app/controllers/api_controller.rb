class ApiController < ApplicationController

  protected
  def render_json(entries = nil)
    render status: response_status, json: [messages, entries]
  end

  def add_error(msg)
    messages[:errors] << msg
  end

  def add_info(msg)
    messages[:info] << msg
  end

  private
  def messages
    @messages ||=
      {errors: [], info: []}
  end

  def response_status
    @response_status ? @response_status : success_or_error
  end

  def success_or_error
    messages[:errors].present? ? :internal_server_error : nil
  end

end
