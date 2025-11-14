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

  context "malformed files (fixtures)" do
    let(:lines) { 0 }

    context "entry line not 27 chars" do
      let(:filename) { "spec/fixtures/malformed_bad_width_line1.txt" }

      it("identifies the offending line and exits 1") do
        stdout, stderr, status = run_script
        expect(stdout).to eq("")
        expect(stderr).to match(/Line 1: expected 27 characters, got 26/)
        expect(status.exitstatus).to eq(1)
      end
    end

    context "separator contains non-space characters" do
      let(:filename) { "spec/fixtures/malformed_bad_separator.txt" }

      it("complains about the separator and exits 1") do
        stdout, stderr, status = run_script
        expect(stdout).to eq("")
        expect(stderr).to match(/separator line/i)
        expect(status.exitstatus).to eq(1)
      end
    end

    context "missing filename" do
      let(:filename) { nil }

      it("prints helpful message and exits 1") do
        stdout, stderr, status = Open3.capture3("ruby", "./po.rb")
        expect(stdout).to eq("")
        expect(stderr).to match(/No input file provided/)
        expect(status.exitstatus).to eq(1)
      end
    end

    context "file does not exist" do
      let(:filename) { "spec/fixtures/does_not_exist.txt" }

      it("prints helpful message and exits 1") do
        stdout, stderr, status = run_script
        expect(stdout).to eq("")
        expect(stderr).to match(/No such file/i)
        expect(status.exitstatus).to eq(1)
      end
    end
  end
end
