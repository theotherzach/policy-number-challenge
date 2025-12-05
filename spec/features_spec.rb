# frozen_string_literal: true

require "open3"
require "tempfile"

RSpec.describe "CLI features" do
  subject(:run_script) { Open3.capture3("ruby", "./po.rb", filename) }

  context "with an output file parameter" do
    let(:input_filename) { "spec/fixtures/sample.txt" }

    it "writes the same content to the file that would have gone to stdout" do
      expected_stdout, = Open3.capture3("ruby", "./po.rb", input_filename)

      Tempfile.create("policy_ocr_output") do |file|
        file_path = file.path
        file.close # this can be a gotcha on some platforms

        success = system("ruby", "./po.rb", input_filename, file_path)
        expect(success).to be true

        written = File.read(file_path)
        expect(written).to eq(expected_stdout)
      end
      # tmpfile handles cleanup automatically
    end
  end

  context "with an empty file" do
    let(:filename) { "spec/fixtures/empty.txt" }

    it("prints nothing to stdout") do
      expect(run_script[0]).to eq("")
    end

    it("exits with code 0") do
      expect(run_script[2].exitstatus).to eq(0)
    end
  end

  context "with a single valid row" do
    let(:filename) { "spec/fixtures/single_row.txt" }
    let(:expected_output) do
      <<~DOC
        000000000
      DOC
    end

    it("prints 9 digits followed by a newline") do
      expect(run_script[0]).to eq(expected_output)
    end

    it("exits with code 0") do
      expect(run_script[2].exitstatus).to eq(0)
    end
  end

  context "with a single il row" do
    let(:filename) { "spec/fixtures/ill_row.txt" }
    let(:expected_output) do
      <<~DOC
        ??3456789 ILL
      DOC
    end

    it("prints ? when it cannot recognize a character") do
      expect(run_script[0]).to eq(expected_output)
    end

    it("exits with code 0") do
      expect(run_script[2].exitstatus).to eq(0)
    end
  end

  context "with 11 rows, all parse, some pass checksum" do
    let(:filename) { "spec/fixtures/sample.txt" }
    let(:expected_output) do
      <<~DOC
        000000000
        711111111
        222222222 ERR
        333393333
        444444444 ERR
        555555555 AMB
        666666666 AMB
        777777177
        888888888 AMB
        999999999 AMB
        123456789
      DOC
    end

    it("prints 11 numbers") do
      expect(run_script[0]).to eq(expected_output)
    end

    it("exits with code 0") do
      expect(run_script[2].exitstatus).to eq(0)
    end
  end

  context "with some rows that can be fixed, some not, some AMB" do
    let(:filename) { "spec/fixtures/fixed.txt" }
    let(:expected_output) do
      <<~DOC
        123456789
        12345?709 ILL
        555555555 AMB
      DOC
    end

    it("prints 11 numbers") do
      expect(run_script[0]).to eq(expected_output)
    end

    it("exits with code 0") do
      expect(run_script[2].exitstatus).to eq(0)
    end
  end

  describe "malformed files" do
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
