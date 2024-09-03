# frozen_string_literal: true

require "bigdecimal"
require "bigdecimal/util"

class ALN
  attr_reader :string, :integer, :fractional

  def initialize(val) # rubocop:disable Metrics/CyclomaticComplexity
    case val
    when Integer
      @integer = val
      @fractional = nil
      @string = encode_int(@integer)
    when Float
      int_part, frac_part = val.to_s.split(".").map(&:to_i)
      @integer = int_part
      @fractional = frac_part
      @string = "#{encode_int(int_part)}.#{encode_int(frac_part)}"
    when BigDecimal
      int_part, frac_part = val.to_s("F").split(".").map(&:to_i)
      @integer = int_part
      @fractional = frac_part
      @string = "#{encode_int(int_part)}.#{encode_int(frac_part)}"
    when String
      raise ArgumentError, "Invalid ALN: #{val}" unless self.class.valid_aln?(val)

      int, frac = decode_aln(val)
      @string = val
      @integer = int
      @fractional = frac
    when Hash
      # Assuming the value is a decimal or ALN
      value = val.values.first
      case value
      when BigDecimal
        int_part, frac_part = value.to_s("F").split(".").map(&:to_i)
        @integer = int_part
        @fractional = frac_part
        @string = "#{encode_int(int_part)}.#{encode_int(frac_part)}"
      when ALN
        @string = value.string
        @integer = value.integer
        @fractional = value.fractional
      end
    else
      raise ArgumentError, "Unsupported type for ALN initialization"
    end
  end

  def to_decimal
    BigDecimal("#{@integer}.#{@fractional || 0}")
  end

  # Helper methods

  def encode_int(int)
    length = int.to_s.length
    prefix = (length + 64).chr
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

  def self.valid_aln?(aln)
    aln.split(".").all? { |segment| valid_aln_segment?(segment) }
  end

  def self.valid_aln_segment?(segment)
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

  # Encode hash method
  def self.encode_hash(obj)
    puts "Encoding #{obj.class}: #{obj}"
    case obj
    when Hash
      obj.each_with_object({}) do |(k, v), new_hash|
        new_hash[k.to_s] = encode_hash(v)
      end
    when Array
      obj.map { |e| encode_hash(e) }
    when Float
      encoded = ALN.new(BigDecimal(obj.to_s)).string
      puts "Encoded Float: #{obj} to #{encoded}"
      encoded
    when Integer
      encoded = ALN.new(obj).string
      puts "Encoded Integer: #{obj} to #{encoded}"
      encoded
    when BigDecimal
      puts "Encoding BigDecimal: #{obj}"
      ALN.new(obj).string
    else
      obj
    end
  end

  # Decode hash method
  def self.decode_hash(obj)
    case obj
    when Hash
      obj.each do |k, v|
        obj[k] = decode_hash(v)
      end
    when Array
      obj.map! { |e| decode_hash(e) }
    when String
      if valid_aln?(obj)
        aln = ALN.new(obj)

        if obj.include?(".")
          aln.to_decimal.to_f
        else
          aln.integer
        end
      else
        obj
      end
    else
      obj
    end
  end
end
