# frozen_string_literal: true

require_relative "../app"
require_relative "context"
require_relative "state"
require_relative "aln"
require "dry-monads"

module Runner
  class Dispatch
    attr_reader :args, :method

    include Dry::Monads[:result]
    def initialize(req_body)
      @body = req_body
    end

    def validate!
      req_check = RequestSchema.call(@body)
      if req_check.success?
        @context = Parser.parse(@body["context"])
        @state = State.new(@body["state"])
        Success(self)
      else
        Failure(req_check.errors)
      end
    end

    def prepare_args!
      @method = @context.call.function.downcase
      raw_args = @context.call.args

      @args = raw_args.transform_keys { |k| k.to_sym }

      # iterate through the args and process ALNs if we see them
      # TODO - this is a horrible hack and types should be properly
      # enforced via the schema
      @args.each do |k, v|
        aln = ALN.new(v)
        @args[k] = aln.to_decimal
      rescue StandardError
        next
      end
    end

    def run!
      instance = App.new(context: @context, state: @state)

      res = instance.public_send(@method, **@args)
      if res.success?
        res.to_h
        { success: true, state: res.result! }

      else
        { success: false, result: { error: res.failure } }
      end
    end
  end
end
