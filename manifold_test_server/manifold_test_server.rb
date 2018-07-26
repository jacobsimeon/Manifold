require "sinatra"
require "fileutils"
require "json"

FILES_DIR = File.expand_path("../files", __FILE__)

class ManifoldTestServer < Sinatra::Base
  get "/files" do
    content_type "application/json"
    Dir[File.join(FILES_DIR, "**")].map { |file|
      { uri: File.join("/files", File.basename(file)) }
    }.to_json
  end

  post "/files" do
    source = params[:file][:tempfile].path
    dest = File.join(FILES_DIR, params[:file][:filename])

    FileUtils.cp(source, dest)
    status 201
  end

  get "/files/:id" do |id|
    send_file File.join(FILES_DIR, id)
  end
end

