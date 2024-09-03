# frozen_string_literal: true

require "json"
require_relative "lib/app"
require_relative "lib/runner"

require "bundler/setup"
require "dry/monads"

# Middleware to parse JSON body
class JSONParser
  include Dry::Monads[:result]

  def initialize(app)
    @app = app
  end

  def call(env)
    if env["CONTENT_TYPE"] == "application/json"
      request = Rack::Request.new(env)
      begin
        env["params"] = JSON.parse(request.body.read)
      rescue JSON::ParserError
        return [400, { "Content-Type" => "application/json" }, [{ error: "Invalid JSON" }.to_json]]
      end
    end
    @app.call(env)
  end
end

use JSONParser

headers = { "content-type" => "application/json" }

run lambda { |env|
  body = env["params"]
  parsed_context = Parser.parse(body["context"])
  # puts body.inspect
  return [400, headers, [JSON.pretty_generate(parsed_context.failure.to_h)]] unless parsed_context.success?

  puts "incoming state: #{body['state']} "

  processed_state = ALN.decode_hash(body["state"])
  app = App.new(context: parsed_context.value!, state: processed_state)

  # app = AppFactory.create(context: parsed.value!, state: body["state"])
  dispatch = Runner::Dispatch.new(body, app)

  result = dispatch.run!
  if result.success?
    response_body = result.value!.to_json
    headers["content-length"] = response_body.bytesize.to_s

    puts "success state: #{response_body}"
    [200, headers, [response_body]]
  else
    response_body = result.failure.to_json
    headers["content-length"] = response_body.bytesize.to_s

    puts "failure return : #{result.failure.to_json}"
    [422, headers, [result.failure.to_json]]
  end
}
