# frozen_string_literal: true

require "spec_helper"
require "rack/test"
require "rack"

require File.expand_path("../../../lib/app", __dir__)

RSpec.describe "JSON Dispatch Functionality" do
  def app
    Rack::Builder.parse_file("config.ru")
  end

  let(:context_json) { File.read("spec/fixtures/transfer_context.json") }
  let(:body) { { context: JSON.parse(context_json), state: {} }.to_json }

  it "passes JSON" do
    allow(Runner::Dispatch).to receive(:new).with(anything)

    post "/", body, "CONTENT_TYPE" => "application/json"
  end

  it "does not forward non-json" do
    post "/", "Hello!", "CONTENT_TYPE" => "text/html"
    expect(Runner::Dispatch).to_not receive(:new)
  end
end
