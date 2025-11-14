# frozen_string_literal: true

require "open3"

RSpec.describe "CLI features" do
  subject(:run_script) { Open3.capture3("ruby", "./po.rb", filename) }

  let(:placeholder)  { "?" * 9 }
  let(:placeholders) { ([placeholder] * lines).join("\n") + "\n" }

  context "with an empty file" do
    let(:filename) { "spec/fixtures/empty.txt" }
    let(:lines) { 0 }

    it("prints nothing to stdout") do
      expect(run_script[0]).to eq("")
    end

    it("exits with code 0") do
      expect(run_script[2].exitstatus).to eq(0)
    end
  end

  context "with a single row" do
    let(:filename) { "spec/fixtures/single_row.txt" }
    let(:lines) { 1 }

    it("prints 9 placeholders followed by a newline") do
      expect(run_script[0]).to eq(placeholders)
    end

    it("exits with code 0") do
      expect(run_script[2].exitstatus).to eq(0)
    end
  end

  context "with 11 rows" do
    let(:filename) { "spec/fixtures/sample.txt" }
    let(:lines) { 11 }

    it("prints 11 lines of 9 placeholders each") do
      expect(run_script[0]).to eq(placeholders)
    end

    it("exits with code 0") do
      expect(run_script[2].exitstatus).to eq(0)
    end
  end
end
