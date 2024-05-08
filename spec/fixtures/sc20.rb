require_relative "../../lib/runner"

class SC20
  include Runner

  attr_accessor :balances, :decimals, :state

  def balances
    state[:balances]
  end

  def groups
    state[:groups]
  end

  def balance(entity:)
    raise "no balance for #{entity}" unless balances[entity]

    balances[entity]
  end

  def mint_to(entity:, amount:)
    raise :unauthorized unless groups[:admins].include?(caller)

    balances[entity] = (balances[entity] || 0) + amount
    state
  end

  def burn_from(entity:, amount:)
    raise :unauthorized unless groups[:admins].include?(caller)

    start_balance = balances[entity] || 0

    raise :insufficient_funds unless start_balance >= amount

    balances[entity] = start_balance - amount
    state
  end

  def mint(to:, amount:)
    raise :unauthorized unless groups[:admins].include?(caller)

    amount = BigDecimal(amount, Float::DIG)
    balances[to] = (balances[to] || 0) + amount
    state
  end

  def get_balance(entity:)
    balances[entity] || 0
  end

  def set_balance(entity:, amount:)
    raise :unauthorized unless groups[:admins].include?(caller)

    puts("setting balance for #{entity} to #{amount}")
    state[:balances] ||= {}

    state[:balances][entity] = amount
  end

  def transfer(from:, to:, amount:)
    amount = BigDecimal(amount, Float::DIG)
    start_balance = balances[from] || 0

    raise :insufficient_funds unless start_balance >= amount
    raise :unauthorized unless from != caller.name

    balances[to] = (balances[to] || 0) + amount
    balances[from] = (start_balance - amount)
    state
  end

  def total_supply(state:)
    state[:balances].values.reduce(0) { |sum, value| sum + value.to_i }
  end
end
