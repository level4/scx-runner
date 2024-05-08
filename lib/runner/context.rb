# frozen_string_literal: true

require "json"
require_relative "schema"
require "dry-monads"

Context = Data.define(:call, :caller, :signers, :targets)

class User
  attr_reader :id, :balance, :groups, :keys

  def initialize(id:, balance:, groups:, keys:)
    @id = id
    @balance = balance
    @groups = groups
    @keys = keys
  end
end

class Caller
  attr_reader :user, :key

  def initialize(key:, user: nil)
    @user = user
    @key = key
  end
end

class Signer
  attr_reader :user, :key

  def initialize(key:, user: nil)
    @user = user
    @key = key
  end
end

class Target
  attr_reader :user, :key

  def initialize(key:, user: nil)
    @user = user
    @key = key
  end
end

class Call
  attr_reader :id, :target, :function, :args, :ttl

  def initialize(id:, target:, function:, args:, ttl:)
    @id = id
    @target = target
    @function = function
    @args = args
    @ttl = ttl
  end
end

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
      user: if context["caller"]["user"]
              User.new(
                id: context["caller"]["user"]["id"],
                groups: context["caller"]["user"]["groups"],
                keys: context["caller"]["user"]["keys"],
                balance: context["caller"]["user"]["balance"]
              )
            else
              nil
            end,
      key: context["caller"]["key"]
    )

    signers = context["signers"].map do |signer|
      Signer.new(
        user: if signer["user"]
                User.new(
                  id: signer["user"]["id"],
                  groups: signer["user"]["groups"],
                  keys: signer["user"]["keys"],
                  balance: signer["user"]["balance"]
                )
              else
                nil
              end,
        key: signer["key"]
      )
    end

    targets = context["targets"].map do |target|
      Target.new(
        user: if target["user"]
                User.new(
                  id: target["user"]["id"],
                  groups: target["user"]["groups"],
                  keys: target["user"]["keys"],
                  balance: target["user"]["balance"]
                )
              else
                nil
              end,
        key: target["key"]
      )
    end

    Context.new(call: call, caller: caller, signers: signers, targets: targets)
  end
end
