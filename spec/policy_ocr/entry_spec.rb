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

  describe "DIGIT_MAP" do
    it "returns '?' for an unrecognized block" do
      invalid_block = [
        "   ".chars,
        "   ".chars,
        "   ".chars
      ]

      expect(described_class::DIGIT_MAP[invalid_block]).to eq("?")
    end
  end
end
