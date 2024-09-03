# frozen_string_literal: true

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

class Context
  attr_reader :call, :caller, :signers, :targets

  def initialize(call:, caller:, signers:, targets:)
    @call = call
    @caller = caller
    @signers = signers
    @targets = targets
  end
end
