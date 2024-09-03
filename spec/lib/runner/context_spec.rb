# frozen_string_literal: true

RSpec.describe Context do
  describe "#parse" do
    let(:json) { File.read("spec/fixtures/transfer_context.json") }
    let(:ctx) { Parser.parse JSON.parse(json) }

    it "rejects invalid context" do
      parse_attempt = Parser.parse({})
      expect(parse_attempt).to be_failure
    end

    it "parses json context" do
      parsed = ctx.value!
      expect(parsed).to be_a(Context)
      expect(parsed.call).to be_a(Call)
      expect(parsed.caller).to be_a(Caller)
      expect(parsed.signers).to all(be_a(Signer))
      expect(parsed.targets).to all(be_a(Target))
    end
  end
end
