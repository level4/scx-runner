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
      expect(ctx).to be_a(Context)
      expect(ctx.call).to be_a(Call)
      expect(ctx.caller).to be_a(Caller)
      expect(ctx.signers).to all(be_a(Signer))
      expect(ctx.targets).to all(be_a(Target))

      # expect { Parser.json('') }.to raise_error(JSON::ParserError)
    end
  end
end
