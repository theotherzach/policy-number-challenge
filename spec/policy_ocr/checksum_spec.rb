# frozen_string_literal: true

require_relative "../../lib/policy_ocr/checksum"

RSpec.describe PolicyOcr::Checksum do
  describe ".valid?" do
    it "returns false for a known invalid policy number" do
      expect(described_class.valid?("000000001")).to be false
    end

    it "returns true for a known valid policy number" do
      expect(described_class.valid?("000000000")).to be true
    end

    it "returns true for a known valid simple policy number" do
      expect(described_class.valid?("000000051")).to be true
    end

    it "returns true for a known non-zero valid policy number" do
      expect(described_class.valid?("457508000")).to be true
    end

    it "returns false for a known non-zero valid policy number" do
      expect(described_class.valid?("457508001")).to be false
    end
  end
end
