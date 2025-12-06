# frozen_string_literal: true

require_relative "policy_ocr/entry"

module PolicyOcr
  class MalformedFile < StandardError; end

  ROWS = 3
  LINES_PER_GROUP = 4
  ROW_LEN = 27

  class << self
    # Raises an error with the given message.
    #
    # @param message [String] the error message
    #   Example: "Line 1: expected 27 characters, got 25"
    # @param error_class [Class] the exception class to raise (default: MalformedFile)
    #   Example: MalformedFile, ArgumentError
    # @raise [MalformedFile, error_class] always raises
    def fail(message, error_class = MalformedFile)
      raise error_class, message
    end

    # Parses an OCR file containing policy numbers and writes results to output.
    #
    # @param filename [String] path to the input file containing OCR data
    #   Example: "data/policy_numbers.txt"
    # @param output_io [IO] the IO object to write parsed results to (default: $stdout)
    #   Example: $stdout, File.open("output.txt", "w"), StringIO.new
    # @return [void]
    # @raise [MalformedFile] if the file format is invalid
    def call(filename, output_io = $stdout)
      validate_filename(filename)

      entry = Array.new(ROWS)

      File.foreach(filename).with_index do |line, index|
        handle_line(entry, line.chomp! || line, index, output_io)
      end

      finalize_entry(entry, output_io)
    end

    private

    # Processes a single line from the OCR file.
    #
    # @param entry [Array<String, nil>] 3-element array accumulating current entry rows
    #   Example: [
    #     " _  _  _  _  _  _  _  _  _ ",
    #     "|_||_||_||_||_||_||_||_||_|",
    #     "|_||_||_||_||_||_||_||_||_|"
    #   ]
    # @param line_body [String] the line content (already chomped)
    #   Example: " _  _  _  _  _  _  _  _  _ "
    # @param index [Integer] zero-based line number in the file
    #   Example: 0, 1, 2, 3
    # @param output_io [IO] the IO object to write parsed results to
    # @return [nil]
    def handle_line(entry, line_body, index, output_io)
      group_index = index % LINES_PER_GROUP

      if group_index < ROWS
        validate_row(line_body, index)
        entry[group_index] = line_body
        nil
      else
        validate_separator(line_body, index)
        output_io.puts(Entry.call(entry))
        entry.fill(nil)
      end
    end

    # Outputs remaining entry if file doesn't end with a separator line.
    #
    # @param entry [Array<String, nil>] the accumulated entry rows
    #   Example: [
    #     " _  _  _  _  _  _  _  _  _ ",
    #     "|_||_||_||_||_||_||_||_||_|",
    #     "|_||_||_||_||_||_||_||_||_|"
    #   ]
    # @param output_io [IO] the IO object to write parsed results to
    # @return [void]
    # @raise [MalformedFile] if entry is incomplete
    def finalize_entry(entry, output_io)
      return if entry.compact.empty?
      fail("File ended without enough lines for a full entry (expected #{ROWS} data lines)") unless entry.all?

      output_io.puts(Entry.call(entry))
    end

    # Validates that a filename is provided.
    #
    # @param filename [String, nil] the filename to validate
    #   Example: "data/policy_numbers.txt", nil, ""
    # @return [void]
    # @raise [MalformedFile] if filename is nil or empty
    def validate_filename(filename)
      fail("No input file provided") if filename.nil? || filename.strip.empty?
    end

    # Validates a data row has correct length and characters.
    #
    # @param line_body [String] the line content to validate
    #   Example: " _  _  _  _  _  _  _  _  _ "
    # @param index [Integer] zero-based line number for error messages
    #   Example: 0, 1, 2
    # @return [void]
    # @raise [MalformedFile] if line is invalid
    def validate_row(line_body, index)
      if line_body.length != ROW_LEN
        fail("Line #{index + 1}: expected #{ROW_LEN} characters, got #{line_body.length}")
      elsif !line_body.match?(/\A[ _|]+\z/)
        fail("Line #{index + 1}: invalid characters; only space, '|' and '_' allowed")
      end
    end

    # Validates that a separator line is blank.
    #
    # @param line_body [String] the line content to validate
    #   Example: "", "   "
    # @param index [Integer] zero-based line number for error messages
    #   Example: 3, 7, 11
    # @return [void]
    # @raise [MalformedFile] if line is not blank
    def validate_separator(line_body, index)
      return if line_body.empty? || line_body.match?(/\A *\z/)

      fail("Line #{index + 1}: expected a blank separator line")
    end
  end
end
