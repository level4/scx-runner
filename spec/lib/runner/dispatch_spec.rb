# frozen_string_literal: true

require "spec_helper"

require File.expand_path("../../../lib/app", __dir__)

RSpec.describe "Dispatch Functionality" do
  let(:context_json) { File.read("spec/fixtures/transfer_context.json") }
  let(:body) { { context: JSON.parse(context_json), state: { 1 => 1 } }.to_json }

  it "passes function arguments" do
    res = Runner::Dispatch.new(JSON.parse(body))
    validation = res.validate!
    expect(validation).to be_success
  end

  it "converts args to symbols, ALNs to decimals" do
    res = Runner::Dispatch.new(JSON.parse(body))
    res.validate!
    res.prepare_args!

    expect(res.args).to eq(amount: 100.0,
                           to: "HtFMpu8LQka2z9BP2BW7KZWn84pqFh2ZxB3ZU56Uo6yk",
                           from: "AvrsEWLMEQgpkem9wfcNgph6G4aRkCVJeiyYo5fu87cb")

    expect(res.args[:amount]).to eq(100.0)
  end

  it "returns an error for malformed context" do
    res = Runner::Dispatch.new(JSON.parse("[]"))
    validation = res.validate!

    expect(validation).to be_failure
  end
end
