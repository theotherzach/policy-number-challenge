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

  describe ".call" do
    it "parses a valid entry and writes its digits to the provided io" do
      io = StringIO.new

      Tempfile.create("ocr") do |file|
        file.write(" _  _  _  _  _  _  _  _  _ \n")
        file.write("| || || || || || || || || |\n")
        file.write("|_||_||_||_||_||_||_||_||_|\n")
        file.write("\n")
        file.flush

        PolicyOcr.call(file.path, io)
      end

      expect(io.string).to eq("000000000\n")
    end
  end
end
