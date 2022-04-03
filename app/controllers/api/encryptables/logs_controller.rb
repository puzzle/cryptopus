class Api::Encryptables::LogsController < ApiController

  def index
    render({ json: fetch_entries,
             root: model_root_key.pluralize }
             .merge(render_options)
             .merge(options.fetch(:render_options, {})))
  end

  def fetch_entries
    logs = current_user.encryptables.find_by(id: params[:id]).versions
    logs.sort { |a, b| b.created_at <=> a.created_at }
  end
end
