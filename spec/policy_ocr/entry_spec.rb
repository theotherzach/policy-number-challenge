# frozen_string_literal: true

require_relative "../../lib/policy_ocr/entry"

RSpec.describe PolicyOcr::Entry do
  describe ".call" do
    context "good number" do
      let(:entry) do
        [
          "    _  _     _  _  _  _  _ ",
          "  | _| _||_||_ |_   ||_||_|",
          "  ||_  _|  | _||_|  ||_| _|"
        ]
      end

      it "returns 9 digits when all blocks are recognized and checksum passes" do
        expect(described_class.call(entry)).to eq("123456789")
      end
    end

    context "ERR number" do
      let(:entry) do
        [
          "                           ",
          "|_||_||_||_||_||_||_||_||_|",
          "  |  |  |  |  |  |  |  |  |"
        ]
      end

      it "appends ILL when digits contain '?'" do
        expect(described_class.call(entry)).to eq("444444444 ERR")
      end
    end

    context "ILL number" do
      let(:entry) do
        [
          "    _  _     _  _  _  _  _ ",
          "  | _| _||_||_ |    || ||_|",
          "  ||_  _|  | _||_|  ||_| _|"
        ]
      end

      it "appends ILL when digits contain '?'" do
        expect(described_class.call(entry)).to eq("12345?709 ILL")
      end
    end

    context "AMB number" do
      let(:entry) do
        [
          "    _  _     _  _  _  _  _ ",
          "  | _| _||_||_ | |  || || |",
          "  ||_  _|  | _||_|  ||_||_|"
        ]
      end

      it "appends ERR when checksum fails" do
        expect(described_class.call(entry)).to eq("123450700 AMB")
      end
    end
  end

  describe "digit map" do
    it "resolves every valid digit block to the correct digit" do
      digit_map = described_class.send(:digit_map)

      digit_map.each do |block, digit|
        # build a num_block-like structure to mirror internal usage
        num_block = { block: block, resolution: "" }
        resolved  = digit_map[num_block.fetch(:block)]

        expect(resolved).to eq(digit)
      end
    end

    it "returns '?' for an unrecognized block" do
      digit_map = described_class.send(:digit_map)

      invalid_block = [
        "   ".chars,
        "   ".chars,
        "   ".chars
      ]

      expect(digit_map[invalid_block]).to eq("?")
    end
  end
end
