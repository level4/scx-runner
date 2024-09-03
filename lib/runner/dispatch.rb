# frozen_string_literal: true

require_relative "../app"
require_relative "context"
require_relative "app_factory"
require_relative "aln"
require "dry-monads"

module Runner
  class Dispatch
    attr_reader :context, :state, :args, :method

    include Dry::Monads[:result]

    def initialize(req_body, app)
      @raw_body = req_body
      @app = app
      load
    end

    def load
      @body = if @raw_body.is_a?(String)
                JSON.parse(@raw_body)
              else
                JSON.parse(JSON.dump(@raw_body))
              end

      valid = validate!
      return valid if valid.failure?

      parsed_context = Parser.parse(@body["context"])
      Failure(parsed_context.failure) if parsed_context.failure?
      @context = parsed_context.value!
      @state = @body["state"]
      @method = @context.call.function.downcase
      raw_args = @context.call.args
      @args = raw_args.transform_keys(&:to_sym).transform_values { |v| parse_arg(v) }
      self
    end

    def validate!
      req_check = RequestSchema.call(@body)
      if req_check.success?
        Success(self)
      else

        Failure(req_check.errors)
      end
    end

    def to_s
      "Dispatch: <function: #{@method} args: #{@args}>"
    end

    def run!
      result = @app.public_send(@method, **@args)
      puts "args: #{@args}"
      if result.success?
        state = result.value!
        # puts "unencoded state: #{state}"
        encoded_state = ALN.encode_hash(state)
        puts "encoded_state: #{encoded_state}"

        # puts JSON.pretty_generate(encoded_state)

        Success(encoded_state)
      else
        Failure(result.failure)
      end
    end

    private

    def parse_arg(value)
      ALN.new(value).to_decimal
    rescue StandardError
      value
    end
  end
end
