# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/runner/aln"

RSpec.describe ALN do
  describe "#initialize" do
    it "initializes with an integer" do
      aln = ALN.new(42)
      expect(aln.integer).to eq(42)
      expect(aln.fractional).to be_nil
      expect(aln.string).to eq("B42")
    end

    it "initializes with a float" do
      aln = ALN.new(42.56)
      expect(aln.integer).to eq(42)
      expect(aln.fractional).to eq(56)
      expect(aln.string).to eq("B42.B56")
    end

    it "initializes with a BigDecimal" do
      decimal = BigDecimal("42.56")
      aln = ALN.new(decimal)
      expect(aln.integer).to eq(42)
      expect(aln.fractional).to eq(56)
      expect(aln.string).to eq("B42.B56")
    end

    it "initializes with a valid ALN string" do
      aln = ALN.new("B42.B56")
      expect(aln.integer).to eq(42)
      expect(aln.fractional).to eq(56)
      expect(aln.string).to eq("B42.B56")
    end

    it "raises an error for an invalid ALN string" do
      expect { ALN.new("invalid") }.to raise_error(ArgumentError)
    end

    it "initializes with a hash containing a BigDecimal" do
      aln = ALN.new({ value: BigDecimal("42.56") })
      expect(aln.integer).to eq(42)
      expect(aln.fractional).to eq(56)
      expect(aln.string).to eq("B42.B56")
    end

    it "initializes with a hash containing an ALN" do
      aln_original = ALN.new(42.56)
      aln = ALN.new({ value: aln_original })
      expect(aln.integer).to eq(42)
      expect(aln.fractional).to eq(56)
      expect(aln.string).to eq("B42.B56")
    end

    it "raises an error for unsupported types" do
      expect { ALN.new([]) }.to raise_error(ArgumentError)
    end
  end

  describe "#to_decimal" do
    it "converts to BigDecimal" do
      aln = ALN.new(42.56)
      expect(aln.to_decimal).to eq(BigDecimal("42.56"))
    end
  end

  describe "encoding and decoding" do
    it "encodes and decodes an integer" do
      encoded = ALN.new(42).string
      decoded = ALN.new(encoded)
      expect(decoded.integer).to eq(42)
      expect(decoded.fractional).to be_nil
    end

    it "encodes and decodes a float" do
      encoded = ALN.new(42.56).string
      decoded = ALN.new(encoded)
      expect(decoded.integer).to eq(42)
      expect(decoded.fractional).to eq(56)
    end
  end

  describe ".encode_hash" do
    it "encodes a hash with floats to ALN strings" do
      data = {
        "balances" => { "key" => 0.9e2 },
        "locked" => false,
        "owner_id" => "owner",
        "total_supply" => 0.9e2
      }
      encoded_data = ALN.encode_hash(data)
      puts "encoded_data: #{encoded_data}"
      expect(encoded_data["balances"]["key"]).to eq("B90.A0")
      expect(encoded_data["total_supply"]).to eq("B90.A0")
    end

    it "encodes a hash with integers to ALN strings" do
      hsh = { balances: { "caller_key" => 900, "receiver_key" => 200 } }
      encoded_data = ALN.encode_hash(hsh)
      expect(encoded_data["balances"]["caller_key"]).to eq("C900")
    end

    it "encodes nested hashes" do
      hsh = { "balances" => { "key1" => 0.1e3 }, "locked" => false,
              "owner_id" => "ABC123", "owner_key" => "owner_key", "total_supply" => BigDecimal("100.0") }

      encoded_data = ALN.encode_hash(hsh)
      expect(encoded_data).to eq({ "balances" => { "key1" => "C100.A0" },
                                   "locked" => false, "owner_id" => "ABC123", "owner_key" => "owner_key", "total_supply" => "C100.A0" })
    end
  end

  describe ".decode_hash" do
    it "decodes a hash with ALN strings to numeric values" do
      data = {
        "balances" => { "key" => "B90.A0" },
        "meta" => { "precision" => "A6", "symbol" => "DATOKEN" },
        "locked" => false,
        "owner_id" => "owner",
        "total_supply" => "B90.A0"
      }
      decoded_data = ALN.decode_hash(data)
      expect(decoded_data["balances"]["key"]).to eq(90.0)
      expect(decoded_data["meta"]["precision"]).to eql(6)
      expect(decoded_data["total_supply"]).to eq(90.0)
    end
  end
end
