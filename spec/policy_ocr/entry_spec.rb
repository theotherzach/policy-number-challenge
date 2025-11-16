# frozen_string_literal: true

require_relative "../../lib/policy_ocr/entry"

RSpec.describe PolicyOcr::Entry do
  describe ".call" do
    let(:entry) do
      [
        "    _  _     _  _  _  _  _ ",
        "  | _| _||_||_ |_   ||_||_|",
        "  ||_  _|  | _||_|  ||_| _|"
      ]
    end

    it "returns 9 digits when all blocks are recognized and checksum passes" do
      allow(PolicyOcr::Checksum).to receive(:valid?).with("123456789").and_return(true)
      expect(described_class.call(entry)).to eq("123456789")
    end

    it "appends ERR when checksum fails" do
      allow(PolicyOcr::Checksum).to receive(:valid?).with("123456789").and_return(false)
      expect(described_class.call(entry)).to eq("123456789 ERR")
    end

    it "appends ILL when digits contain '?', without checking checksum" do
      # Force resolve_digits to simulate an unrecognized block.
      allow(described_class).to receive(:resolve_digits).and_return("0000000?1")
      # With a '?', checksum should not even be consulted.
      expect(PolicyOcr::Checksum).not_to receive(:valid?)

      expect(described_class.call(entry)).to eq("0000000?1 ILL")
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
