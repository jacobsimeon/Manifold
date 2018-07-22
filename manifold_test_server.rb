require "sinatra"

class ManifoldTestServer < Sinatra::Base
  get "/" do
    "Hello World"
  end
end
