# frozen_string_literal: true

require_relative "../lib/policy_ocr"

describe PolicyOcr do
  it "loads" do
    expect(PolicyOcr).to be_a Module
  end

  it "loads the sample.txt" do
    expect(fixture("sample").lines.count).to eq(44)
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
          { block: [[" ", " ", " "], [" ", " ", "|"], [" ", " ", "|"]], resolution: "?" },
          { block: [[" ", "_", " "], [" ", "_", "|"], ["|", "_", " "]], resolution: "?" },
          { block: [[" ", "_", " "], [" ", "_", "|"], [" ", "_", "|"]], resolution: "?" },
          { block: [[" ", " ", " "], ["|", "_", "|"], [" ", " ", "|"]], resolution: "?" },
          { block: [[" ", "_", " "], ["|", "_", " "], [" ", "_", "|"]], resolution: "?" },
          { block: [[" ", "_", " "], ["|", "_", " "], ["|", "_", "|"]], resolution: "?" },
          { block: [[" ", "_", " "], [" ", " ", "|"], [" ", " ", "|"]], resolution: "?" },
          { block: [[" ", "_", " "], ["|", "_", "|"], ["|", "_", "|"]], resolution: "?" },
          { block: [[" ", "_", " "], ["|", "_", "|"], [" ", "_", "|"]], resolution: "?" }
        ]
      end

      it "returns 9 num_blocks" do
        expect(described_class.create_num_blocks(entry)).to eq(expected_result)
      end
    end
  end
end
