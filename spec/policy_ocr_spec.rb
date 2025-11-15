# frozen_string_literal: true

require "stringio"
require_relative "../lib/policy_ocr"

describe PolicyOcr do
  it "loads" do
    expect(PolicyOcr).to be_a Module
  end

  it "loads the sample.txt" do
    expect(fixture("sample").lines.count).to eq(44)
  end

  describe ".fail" do
    it "raises a MalformedFile error with the given message" do
      expect { described_class.fail("bad things") }
        .to raise_error(described_class::MalformedFile, "bad things")
    end
  end

  describe ".handle_line" do
    let(:line1) { "    _  _     _  _  _  _  _ " }
    let(:line2) { "  | _| _||_||_ |_   ||_||_|" }
    let(:line3) { "  ||_  _|  | _||_|  ||_| _|" }
    let(:separator) { "" }
    let(:output_io) { StringIO.new }

    it "returns num_blocks on the separator line after receiving 3 data lines" do
      entry = Array.new(3)

      expect(described_class.handle_line(entry, line1, 0, output_io)).to be_nil
      expect(described_class.handle_line(entry, line2, 1, output_io)).to be_nil
      expect(described_class.handle_line(entry, line3, 2, output_io)).to be_nil

      result = described_class.handle_line(entry, separator, 3, output_io)

      expect(entry.compact).to be_empty
      expect(result.map { |nb| nb[:resolution] }).to eq(%w[1 2 3 4 5 6 7 8 9])
    end
  end

  describe ".create_num_blocks" do
    context "happy path" do
      let(:entry) do
        ["    _  _     _  _  _  _  _ ",
         "  | _| _||_||_ |_   ||_||_|",
         "  ||_  _|  | _||_|  ||_| _|"]
      end

      let(:expected_result) do
        [
          { block: [[" ", " ", " "], [" ", " ", "|"], [" ", " ", "|"]], resolution: "1" },
          { block: [[" ", "_", " "], [" ", "_", "|"], ["|", "_", " "]], resolution: "2" },
          { block: [[" ", "_", " "], [" ", "_", "|"], [" ", "_", "|"]], resolution: "3" },
          { block: [[" ", " ", " "], ["|", "_", "|"], [" ", " ", "|"]], resolution: "4" },
          { block: [[" ", "_", " "], ["|", "_", " "], [" ", "_", "|"]], resolution: "5" },
          { block: [[" ", "_", " "], ["|", "_", " "], ["|", "_", "|"]], resolution: "6" },
          { block: [[" ", "_", " "], [" ", " ", "|"], [" ", " ", "|"]], resolution: "7" },
          { block: [[" ", "_", " "], ["|", "_", "|"], ["|", "_", "|"]], resolution: "8" },
          { block: [[" ", "_", " "], ["|", "_", "|"], [" ", "_", "|"]], resolution: "9" }
        ]
      end

      it "returns 9 num_blocks" do
        output_io = StringIO.new
        expect(described_class.create_num_blocks(entry, output_io)).to eq(expected_result)
      end
    end
  end

  describe ".output" do
    let(:io) { StringIO.new }

    it "writes a valid checksum line without ERR" do
      # 000000051 is a valid checksum under our rule
      digits = "000000051"
      num_blocks = digits.chars.map { |ch| { block: nil, resolution: ch } }

      result = described_class.output(num_blocks, io)

      expect(io.string).to eq("000000051\n")
      expect(result).to eq(num_blocks)
    end

    it "writes an invalid checksum line with ERR" do
      # 000000050 is invalid
      digits = "000000050"
      num_blocks = digits.chars.map { |ch| { block: nil, resolution: ch } }

      described_class.output(num_blocks, io)

      expect(io.string).to eq("000000050 ERR\n")
    end

    it "writes digits with '?' without appending ERR" do
      digits = "0000000?1"
      num_blocks = digits.chars.map { |ch| { block: nil, resolution: ch } }

      described_class.output(num_blocks, io)

      expect(io.string).to eq("0000000?1\n")
    end
  end

  describe ".resolve_num_block" do
    it "resolves every valid digit block to the correct digit" do
      described_class.digit_map.each do |block, digit|
        num_block = { block: block, resolution: "" }

        described_class.resolve_num_block(num_block)

        expect(num_block[:resolution]).to eq(digit)
      end
    end

    it "returns '?' for an unrecognized block" do
      invalid_block = [
        "   ".chars,
        "   ".chars,
        "   ".chars
      ]

      num_block = { block: invalid_block, resolution: "" }

      described_class.resolve_num_block(num_block)

      expect(num_block[:resolution]).to eq("?")
    end
  end
end
