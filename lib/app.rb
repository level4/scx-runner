# frozen_string_literal: true

require "dry-monads"

class App
  include Dry::Monads[:result]

  def initialize(context:, state:)
    @context = context
    @state = state
    @caller_keys = @context.caller.user.keys.values if @context.caller.user
  end

  def init
    return Failure(:already_initialized) unless @state.empty?

    @state[:balances] = {}
    @state[:locked] = false
    @state[:owner_key] = @context.caller.key
    @state[:owner_id] = @context.caller.user.id
    @state[:meta] = {
      spec: "grc/20",
      precision: 6,
      symbol: "DATOKEN",
      total_supply: 0
    }

    Success(@state)
  end

  def transfer(amount:, from:, to:)
    return Failure(:unauthorized) unless @caller_keys.include?(from)
    return Failure(:locked) if @state["locked"]

    @state["balances"][to] ||= 0
    from_balance = @state["balances"][from] || 0
    if from_balance < amount
      Failure(:insufficient_funds)
    else
      @state["balances"][from] -= amount
      @state["balances"][to] += amount
      Success(@state)
    end
  end

  def mint(amount:, to:)
    puts @state.inspect
    unless caller_is_owner?
      puts "expected #{@caller_keys} to include #{@state['owner_key']}"
      return Failure(:unauthorized)
    end

    puts "minting #{amount.inspect} to #{to}"
    puts "@state[balances][to]: #{@state['balances'][to].inspect}"

    @state["balances"][to] ||= 0
    @state["balances"][to] += amount
    @state["meta"]["total_supply"] += amount
    Success(@state)
  end

  def lock
    return Failure(:unauthorized) unless caller_is_owner?

    @state[:locked] = true
    Success(@state)
  end

  def unlock
    return Failure(:unauthorized) unless caller_is_owner?

    @state[:locked] = false
    Success(@state)
  end

  def caller_is_owner?
    @caller_keys.include?(@state["owner_key"])
  end

  require "nokogiri"
  require "open-uri"
  def nytimes
    return Failure(:unauthorized) unless caller_is_owner?

    url = "https://www.nytimes.com/"
    html = URI.open(url)
    doc = Nokogiri::HTML(html)

    story_wrapper = doc.css("section.story-wrapper").first
    headline = story_wrapper.css("p").find { |p| p["class"] && p["class"].include?("indicate-hover") }
    headline ? headline.text.strip : "Headline not found"
  end
end
