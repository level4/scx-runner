# frozen_string_literal: true

require "rspec"
require "dry-monads"
require_relative "../../lib/app"

RSpec.describe App do
  let(:caller) { double("Caller", key: "caller_key", user: double("User", id: 1, keys: ["caller_key"])) }
  let(:context) { double("Context", caller: caller) }
  let(:state) { {} }
  let(:app) { App.new(context: context, state: state) }

  describe "#init" do
    context "when state is empty" do
      it "initializes the state" do
        result = app.init
        expect(result).to be_success
        expect(result.value!).to eq(
          balances: {},
          locked: false,
          total_supply: 0,
          owner_key: "caller_key",
          owner_id: 1
        )
      end
    end

    context "when state is not empty" do
      let(:state) { { balances: { "caller_key" => 1000 } } }

      it "fails to initialize" do
        result = app.init
        expect(result).to be_failure
        expect(result.failure).to eq(:already_initialized)
      end
    end
  end

  describe "#transfer" do
    before do
      state[:balances] = { "caller_key" => 1000, "receiver_key" => 100 }
      state[:locked] = false
    end

    context "when transfer is authorized" do
      it "transfers the amount" do
        result = app.transfer(amount: 100, from: "caller_key", to: "receiver_key")
        expect(result).to be_success
        expect(result.value![:balances]).to eq(
          "caller_key" => 900,
          "receiver_key" => 200
        )
      end
    end

    context "when transfer is unauthorized" do
      let(:caller) { double("Caller", key: "caller_key", user: double("User", id: 1, keys: [])) }

      it "fails the transfer" do
        result = app.transfer(amount: 100, from: "caller_key", to: "receiver_key")
        expect(result).to be_failure
        expect(result.failure).to eq(:unauthorized)
      end
    end

    context "when state is locked" do
      before { state[:locked] = true }

      it "fails the transfer" do
        result = app.transfer(amount: 100, from: "caller_key", to: "receiver_key")
        expect(result).to be_failure
        expect(result.failure).to eq(:locked)
      end
    end

    context "when balance is insufficient" do
      it "fails the transfer" do
        result = app.transfer(amount: 2000, from: "caller_key", to: "receiver_key")
        expect(result).to be_failure
        expect(result.failure).to eq(:insufficient_funds)
      end
    end
  end

  describe "#mint" do
    context "when caller is the owner" do
      it "mints new tokens" do
        app.init
        result = app.mint(amount: 500, to: "caller_key")
        expect(result).to be_success
        expect(result.value![:balances]["caller_key"]).to eq(500)
        expect(result.value![:total_supply]).to eq(500)
      end
    end

    context "when caller is not the owner" do
      let(:caller) { double("Caller", key: "caller_key", user: double("User", id: 1, keys: ["another_key"])) }

      it "fails to mint tokens" do
        app.init
        result = app.mint(amount: 500, to: "caller_key")
        expect(result).to be_failure
        expect(result.failure).to eq(:unauthorized)
      end
    end
  end

  describe "#lock" do
    before { app.init }

    context "when caller is the owner" do
      it "locks the contract" do
        result = app.lock
        expect(result).to be_success
        expect(result.value![:locked]).to be true
      end
    end

    context "when caller is not the owner" do
      let(:caller) { double("Caller", key: "caller_key", user: double("User", id: 1, keys: ["another_key"])) }

      it "fails to lock the contract" do
        result = app.lock
        expect(result).to be_failure
        expect(result.failure).to eq(:unauthorized)
      end
    end
  end

  describe "#unlock" do
    before do
      app.init
      app.lock
    end

    context "when caller is the owner" do
      it "unlocks the contract" do
        result = app.unlock
        expect(result).to be_success
        expect(result.value![:locked]).to be false
      end
    end

    context "when caller is not the owner" do
      let(:caller) { double("Caller", key: "caller_key", user: double("User", id: 1, keys: ["another_key"])) }

      it "fails to unlock the contract" do
        result = app.unlock
        expect(result).to be_failure
        expect(result.failure).to eq(:unauthorized)
      end
    end
  end
end
