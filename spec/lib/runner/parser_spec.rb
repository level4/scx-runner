# frozen_string_literal: true

require "rspec"
require File.expand_path("../../../lib/runner/parser", __dir__)
require File.expand_path("../../../lib/runner/schema", __dir__)
require File.expand_path("../../../lib/runner/models", __dir__)

RSpec.describe Parser do
  let(:valid_context) do
    {
      "call" => {
        "id" => "1",
        "target" => "target_id",
        "function" => "test_function",
        "args" => { "key" => "value" },
        "ttl" => 300
      },
      "caller" => {
        "key" => "caller_key",
        "user" => {
          "id" => "user_id",
          "balance" => "1000.0",
          "groups" => %w[group1 group2],
          "keys" => { "key1" => "value1" }
        }
      },
      "signers" => [
        {
          "key" => "signer_key",
          "user" => {
            "id" => "signer_id",
            "balance" => "500.0",
            "groups" => ["group1"],
            "keys" => { "key2" => "value2" }
          }
        }
      ],
      "targets" => [
        {
          "key" => "target_key",
          "user" => {
            "id" => "target_id",
            "balance" => "300.0",
            "groups" => ["group2"],
            "keys" => { "key3" => "value3" }
          }
        }
      ]
    }
  end

  describe ".parse" do
    context "with valid context" do
      it "parses the context successfully" do
        result = Parser.parse(valid_context)
        expect(result).to be_success
        parsed_context = result.value!
        expect(parsed_context).to be_a(Context)
        expect(parsed_context.call).to be_a(Call)
        expect(parsed_context.caller).to be_a(Caller)
        expect(parsed_context.signers.first).to be_a(Signer)
        expect(parsed_context.targets.first).to be_a(Target)
      end
    end

    context "with invalid context" do
      let(:invalid_context) { valid_context.merge("call" => { "id" => nil }) }

      it "returns failure" do
        result = Parser.parse(invalid_context)
        expect(result).to be_failure
      end
    end
  end
end
