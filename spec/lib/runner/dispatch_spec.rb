# frozen_string_literal: true

require "spec_helper"

require File.expand_path("../../../lib/app", __dir__)

RSpec.describe Runner::Dispatch do
  let(:json) { File.read("spec/fixtures/transfer_context.json") }
  let(:state) { {} }
  let(:input) { { "context" => JSON.parse(json), "state" => state } }
  let(:app) { instance_double(App) }
  let(:dispatch) { described_class.new(input, app) }

  before do
    allow(app).to receive(:transfer).and_return(Dry::Monads::Success(balances:
     { "caller_key" => 900,
       "receiver_key" => 200 }))
  end

  describe "#initialize" do
    it "initializes with request body" do
      expect { dispatch }.not_to raise_error
    end
  end

  describe "#validate!" do
    it "validates the request successfully" do
      expect(dispatch.method).to eq("transfer")
    end
  end

  describe "#run!" do
    it "runs the requested method and returns success" do
      result = dispatch.run!
      expect(result).to be_success
      expect(app).to have_received(:transfer).with(amount: 0.1e3,
                                                   from: "AvrsEWLMEQgpkem9wfcNgph6G4aRkCVJeiyYo5fu87cb",
                                                   to: "HtFMpu8LQka2z9BP2BW7KZWn84pqFh2ZxB3ZU56Uo6yk")
    end

    it "encodes the new state using ALN.encode_hash" do
      result = dispatch.run!
      expect(result).to be_success
      encoded_state = result.value!
      puts "encoded_state: #{encoded_state}"
      expect(encoded_state["balances"]).to eq({ "caller_key" => "C900", "receiver_key" => "C200" })
    end
  end
end
