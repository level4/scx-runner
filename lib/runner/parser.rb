# frozen_string_literal: true

require "dry-monads"
require_relative "models"
require_relative "schema"

module Parser
  extend Dry::Monads[:result]

  def self.parse(context)
    result = ContextSchemaBasic.call(context)
    return Failure(result.errors) unless result.success?

    call = Call.new(
      id: context["call"]["id"],
      target: context["call"]["target"],
      function: context["call"]["function"],
      args: context["call"]["args"],
      ttl: context["call"]["ttl"]
    )

    caller = Caller.new(
      key: context["caller"]["key"],
      user: parse_user(context["caller"]["user"])
    )

    signers = (context["signers"] || []).map do |signer|
      Signer.new(
        key: signer["key"],
        user: parse_user(signer["user"])
      )
    end

    targets = (context["targets"] || []).map do |target|
      Target.new(
        key: target["key"],
        user: parse_user(target["user"])
      )
    end

    Success(Context.new(call: call, caller: caller, signers: signers, targets: targets))
  end

  def self.parse_user(user_data)
    return nil unless user_data

    User.new(
      id: user_data["id"],
      balance: user_data["balance"],
      groups: user_data["groups"],
      keys: user_data["keys"]
    )
  end
end
