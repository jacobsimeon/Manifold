$: << File.expand_path("../", __FILE__)
require "manifold_test_server"

class Rack::Lint::InputWrapper
  def eof?
    @input.eof?
  end
end

ManifoldTestServer.run!(bind: "0.0.0.0", port: "8080")
