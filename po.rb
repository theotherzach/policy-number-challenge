#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "lib/policy_ocr"

HELP_TEXT = <<~HELP
  Usage: ./po.rb INPUT_FILE [OUTPUT_FILE]

  Parse OCR-encoded policy numbers from INPUT_FILE and write the results to
  stdout or to OUTPUT_FILE if provided.

  Arguments:
    INPUT_FILE      Path to a text file containing one or more OCR entries.
                    Each entry must be 4 lines:
                      * Lines 1–3: 27-character OCR digit rows
                      * Line 4:    blank separator line

    OUTPUT_FILE     Optional. If provided, output is written to this file
                    instead of stdout.

  Behavior:
    * Valid OCR rows are converted into 9-digit policy numbers.
    * Rows containing unrecognized digits produce '?' characters.
    * Rows failing the checksum are marked with "ERR".
    * Rows containing '?' digits are marked with "ILL".
    * Future: rows may be corrected using single-character fixes.

  Exit Codes:
    0   Success
    1   Invalid input file, malformed OCR entry, or unreadable file

  Examples:
    # Decode OCR entries and print results to the console
    ./po.rb sample.txt

      457508000
      664371495 ERR
      86110??36 ILL
      490067715
      000000051
      128371904 ERR
      70342?71? ILL

    # Write results to an output file
    ./po.rb sample.txt results.txt

    # Display this help text
    ./po.rb -h
    ./po.rb --help
HELP

# Handle -h / --help early and exit
if ["-h", "--help"].include?(ARGV[0])
  puts HELP_TEXT
  exit 0
end

begin
  input_filename  = ARGV[0]
  output_filename = ARGV[1]

  if output_filename
    File.open(output_filename, "w") do |file|
      PolicyOcr.call(input_filename, file)
    end
  else
    PolicyOcr.call(input_filename)
  end
rescue PolicyOcr::MalformedFile, Errno::ENOENT => e
  warn e.message
  exit 1
end
