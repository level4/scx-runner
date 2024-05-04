RSpec.describe Context do
  describe '#parse' do
    let(:json) { File.read("spec/fixtures/context.json") }
    let(:ctx) { Parser.json json }

    it 'parses json context' do
      expect(ctx).to be_a(Context)
      expect(ctx.call).to be_a(Call)
      expect(ctx.caller).to be_a(Caller)
      expect(ctx.signers).to all(be_a(Signer))
      expect(ctx.targets).to all(be_a(Target))

      expect { Parser.json('') }.to raise_error(JSON::ParserError)
    end
  end
end
