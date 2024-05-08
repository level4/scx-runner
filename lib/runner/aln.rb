# frozen_string_literal: true

require "bigdecimal"
require "bigdecimal/util"

class ALN
  attr_reader :string, :integer, :fractional

  def initialize(val)
    case val
    when Integer
      @integer = val
      @fractional = nil
      @string = encode_int(@integer)
    when Float
      raise ArgumentError, "Do not use or try to encode floats. They lose formatting. Sent: #{val}"
    when BigDecimal
      int_part, frac_part = val.split
      @integer = int_part.to_i
      @fractional = frac_part * (10**frac_part.exponent).to_i
      @string = "#{encode_int(@integer)}.#{encode_int(@fractional)}"
    when String
      raise ArgumentError, "Invalid ALN: #{val}" unless valid_aln?(val)

      int, frac = decode_aln(val)
      @string = val
      @integer = int
      @fractional = frac

    when Hash
      initialize(ALN.new(val.values.first))
    else
      raise ArgumentError, "Unsupported type for ALN initialization"
    end
  end

  def to_decimal
    BigDecimal("#{@integer}.#{@fractional || 0}")
  end

  # Helper methods

  def encode_int(int)
    prefix = (int.to_s.length + 64).chr
    "#{prefix}#{int}"
  end

  def decode_aln(aln)
    if aln.include?(".")
      parts = aln.split(".")
      [decode_segment(parts[0]), decode_segment(parts[1])]
    else
      [decode_segment(aln), nil]
    end
  end

  def decode_segment(segment)
    prefix = segment[0].ord - 64
    num_str = segment[1..-1]
    num = num_str.to_i
    raise ArgumentError, "Invalid segment: #{segment}" unless prefix == num_str.length

    num
  end

  def valid_aln?(aln)
    aln.split(".").all? { |segment| valid_aln_segment?(segment) }
  end

  def valid_aln_segment?(segment)
    prefix = segment[0].ord - 64
    num_str = segment[1..-1]
    num_str.length == prefix && num_str =~ /^\d+$/
  end

  # Arithmetic operations

  def +(other)
    result = to_decimal + other.to_decimal
    ALN.new(result)
  end

  def -(other)
    result = to_decimal - other.to_decimal
    ALN.new(result)
  end
end
