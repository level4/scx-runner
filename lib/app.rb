# frozen_string_literal: true

require "dry-monads"

class App
  include Dry::Monads[:result]
  def initialize(context:, state:)
    puts "instance initialized"
    @context = context
    @state = state
    @caller_keys = @context.caller.user.keys.values
  end

  def init
    return Failure(:already_initialized) unless @state == {}

    @state[:balances] = {}
    @state[:locked] = false
    @state[:total_supply] = 0
    @state[:owner_key] = @context.caller.key
    @state[:owner_id] = @context.caller.user.id
    Success(@state)
  end

  # It's preferable to store under system IDs, but you can also use specific keys
  def transfer(amount:, from:, to:)
    # perform additional checks that the sender owns the balance as you wish
    return Failure(:unauthorized) unless @caller_keys.include?(from)

    return Failure(:locked) if @state[:locked]

    @state[:balances][to] ||= 0
    from_balance = @state[:balances][from] || 0
    if from_balance < amount
      Failure(:insufficient_funds)
    else
      @state[:balances][from] -= amount
      @state[:balances][to] += amount
      Success(@state)
    end
  end

  def mint(amount:, to:)
    return Failure(:unauthorized) unless @caller_keys.include?(@state[:owner_key])

    @state[:balances][to] ||= 0
    @state[:balances][to] += amount
    @state[:total_supply] += amount
    Success(@state)
  end

  def lock
    return Failure(:unauthorized) unless @caller_keys.include?(@state[:owner_key])

    @state[:locked] = true
    Success(@state)
  end

  def unlock
    return Failure(:unauthorized) unless @caller_keys.include?(@state[:owner_key])

    @state[:locked] = false
    Success(@state)
  end
end
