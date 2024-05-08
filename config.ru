# frozen_string_literal: true

require "json"
require_relative "lib/app"
require_relative "lib/runner"

require "bundler/setup"

use Rack::Lint

# Middleware to parse JSON body
class JSONParser
  def initialize(app)
    @app = app
  end

  def call(env)
    if env["CONTENT_TYPE"] == "application/json"
      request = Rack::Request.new(env)
      env["params"] = JSON.parse(request.body.read)
    end
    @app.call(env)
  end
end

use JSONParser

headers = { "content-type" => "application/json" }

run lambda { |env|
  body = env["params"]
  parsed = Parser.parse(body)
  return [400, headers, [parsed.failure.messages.to_json]] unless parsed.success?

  dispatch = Runner::Dispatch.new(body)

  result = dispatch.run!
  if result.success?
    [200, headers, [result.to_json]]
  else
    [400, headers, [result.failure.to_json]]
  end
}
