# frozen_string_literal: true

require_relative "checksum"

module PolicyOcr
  module Entry
    ILL = "ILL"
    ERR = "ERR"
    AMB = "AMB"
    NUM_DIGITS = 9
    GRID_SIZE = 3

    DIGIT_MAP = Hash.new("?").merge(
      [
        " _ ".chars.freeze,
        "| |".chars.freeze,
        "|_|".chars.freeze
      ].freeze => "0",
      [
        "   ".chars.freeze,
        "  |".chars.freeze,
        "  |".chars.freeze
      ].freeze => "1",
      [
        " _ ".chars.freeze,
        " _|".chars.freeze,
        "|_ ".chars.freeze
      ].freeze => "2",
      [
        " _ ".chars.freeze,
        " _|".chars.freeze,
        " _|".chars.freeze
      ].freeze => "3",
      [
        "   ".chars.freeze,
        "|_|".chars.freeze,
        "  |".chars.freeze
      ].freeze => "4",
      [
        " _ ".chars.freeze,
        "|_ ".chars.freeze,
        " _|".chars.freeze
      ].freeze => "5",
      [
        " _ ".chars.freeze,
        "|_ ".chars.freeze,
        "|_|".chars.freeze
      ].freeze => "6",
      [
        " _ ".chars.freeze,
        "  |".chars.freeze,
        "  |".chars.freeze
      ].freeze => "7",
      [
        " _ ".chars.freeze,
        "|_|".chars.freeze,
        "|_|".chars.freeze
      ].freeze => "8",
      [
        " _ ".chars.freeze,
        "|_|".chars.freeze,
        " _|".chars.freeze
      ].freeze => "9"
    ).freeze

    class << self
      # Parses a 3-row OCR entry and returns the policy number with status.
      #
      # @param entry [Array<String>] 3-element array of 27-char OCR rows
      #   Example: [
      #     "    _  _     _  _  _  _  _ ",
      #     "  | _| _||_||_ |_   ||_||_|",
      #     "  ||_  _|  | _||_|  ||_| _|"
      #   ]
      # @return [String] policy number, optionally with error suffix
      #   Example: "123456789", "1234?6789 ILL", "123456789 ERR", "123456789 AMB"
      def call(entry)
        blocks = build_blocks(entry)
        digits = resolve_digits(blocks)
        error = error_for(digits)
        return format_line(digits, error) if error.nil?

        attempt_correction(blocks, digits, error)
      end

      private

      # Attempts to fix an invalid policy number by trying single-character replacements.
      #
      # @param blocks [Array<Array<Array<String>>>] array of 9 3x3 character grids
      #   Example block for digit "0": [
      #     [" ", "_", " "],
      #     ["|", " ", "|"],
      #     ["|", "_", "|"]
      #   ]
      # @param orig_digits [String] the original 9-character digit string
      #   Example: "12?456789", "123456788"
      # @param orig_error [String] the original error code
      #   Example: "ILL", "ERR"
      # @return [String] corrected policy number or original with error suffix
      #   Example: "123456789", "12?456789 ILL", "123456789 AMB"
      def attempt_correction(blocks, orig_digits, orig_error)
        candidates = make_candidates(blocks, orig_digits)

        case candidates.size
        when 0
          format_line(orig_digits, orig_error)
        when 1
          format_line(candidates.first, nil)
        else
          format_line(orig_digits, AMB)
        end
      end

      # Generates all valid candidate corrections for an invalid policy number.
      #
      # @param blocks [Array<Array<Array<String>>>] array of 9 3x3 character grids
      # @param orig_digits [String] the original 9-character digit string
      #   Example: "12?456789"
      # @return [Set<String>] set of valid corrected digit strings
      #   Example: Set["123456789"], Set["123456789", "129456789"]
      def make_candidates(blocks, orig_digits)
        candidates = Set.new

        blocks.each_with_index do |block, index|
          next if bad_char_elsewhere?(orig_digits, index)

          collect_candidates(candidates, block, orig_digits, index)
        end

        candidates
      end

      # Collects valid corrections for a single digit position.
      #
      # @param candidates [Set<String>] set to add valid candidates to
      # @param block [Array<Array<String>>] 3x3 character grid for one digit
      #   Example: [
      #     [" ", "_", " "],
      #     ["|", " ", "|"],
      #     ["|", "_", "|"]
      #   ]
      # @param orig_digits [String] the original 9-character digit string
      #   Example: "12?456789"
      # @param index [Integer] position (0-8) being checked
      #   Example: 2
      # @return [void]
      def collect_candidates(candidates, block, orig_digits, index)
        block.each_with_index do |row, ri|
          row.each_with_index do |char, ci|
            replacements_for(char).each do |replacement|
              new_digit = safe_make_digit(block, replacement, ri, ci)

              next if new_digit == "?"

              new_digits = build_digit(orig_digits, new_digit, index)

              error = error_for(new_digits)

              next unless error.nil?

              candidates << new_digits

              return candidates if candidates.size > 1
            end
          end
        end
      end

      # Returns possible replacement characters for OCR correction.
      #
      # @param char [String] the current OCR character
      #   Example: " ", "_", "|"
      # @return [Array<String>] possible replacement characters
      #   Example: ["_", "|"], [" ", "|"], [" ", "_"], []
      def replacements_for(char)
        case char
        when " "
          ["_", "|"]
        when "_"
          [" ", "|"]
        when "|"
          [" ", "_"]
        else
          []
        end
      end

      # Checks if there are unrecognized digits at positions other than the current index.
      # We can only fix a digit if "?" appears solely at the index we're correcting.
      # If "?" exists elsewhere, we cannot generate a valid candidate from this position.
      #
      # @param digits [String] the digit string to check
      #   Example: "1?3456789", "123456789", "1?3?56789"
      # @param index [Integer] position to exclude from check
      #   Example: 1, 2
      # @return [Boolean] true if "?" exists at positions other than index
      #   Example: bad_char_elsewhere?("1?3456789", 1) => false
      #   Example: bad_char_elsewhere?("1?3456789", 2) => true
      #   Example: bad_char_elsewhere?("1?3?56789", 1) => true
      def bad_char_elsewhere?(digits, index)
        digits.each_char.with_index.any? { |char, i| char == "?" && i != index }
      end

      # Attempts to recognize a digit after a single character replacement.
      #
      # @param block [Array<Array<String>>] 3x3 character grid for one digit
      #   Example: [
      #     [" ", "_", " "],
      #     ["|", " ", "|"],
      #     ["|", "_", "|"]
      #   ]
      # @param replacement [String] the replacement character
      #   Example: "_", "|", " "
      # @param row_index [Integer] row position (0-2) to modify
      #   Example: 0, 1, 2
      # @param char_index [Integer] column position (0-2) to modify
      #   Example: 0, 1, 2
      # @return [String] the recognized digit or "?" if unrecognized
      #   Example: "0", "8", "?"
      def safe_make_digit(block, replacement, row_index, char_index)
        original = block.fetch(row_index).fetch(char_index)
        block[row_index][char_index] = replacement
        new_digit = DIGIT_MAP[block]
        block[row_index][char_index] = original
        new_digit
      end

      # Builds a new digit string by replacing one character.
      #
      # @param orig_digits [String] the original 9-character digit string
      #   Example: "1?3456789"
      # @param new_digit [String] the replacement digit
      #   Example: "2"
      # @param index [Integer] position (0-8) to replace
      #   Example: 1
      # @return [String] the new digit string
      #   Example: "123456789"
      def build_digit(orig_digits, new_digit, index)
        digits_array = orig_digits.chars
        digits_array[index] = new_digit
        digits_array.join
      end

      # Parses OCR rows into digit blocks.
      #
      # @param entry [Array<String>] 3-element array of 27-char OCR rows
      #   Example: [
      #     "    _  _     _  _  _  _  _ ",
      #     "  | _| _||_||_ |_   ||_||_|",
      #     "  ||_  _|  | _||_|  ||_| _|"
      #   ]
      # @return [Array<Array<Array<String>>>] array of 9 3x3 character grids
      #   Example for digit "1": [
      #     [" ", " ", " "],
      #     [" ", " ", "|"],
      #     [" ", " ", "|"]
      #   ]
      def build_blocks(entry)
        blocks = Array.new(NUM_DIGITS) { [] }

        entry.each do |row|
          row.chars.each_slice(GRID_SIZE).with_index do |chars, i|
            blocks[i] << chars
          end
        end

        blocks
      end

      # Converts blocks to digit characters.
      #
      # @param blocks [Array<Array<Array<String>>>] array of 9 3x3 character grids
      # @return [String] concatenated digit string
      #   Example: "123456789"
      def resolve_digits(blocks)
        blocks.map { |block| DIGIT_MAP[block] }.join
      end

      # Determines the error status for a digit string.
      #
      # @param digits [String] the 9-character digit string
      #   Example: "123456789", "1?3456789", "123456788"
      # @return [String, nil] error code or nil if valid
      #   Example: nil, "ILL", "ERR"
      def error_for(digits)
        return ILL if digits.include?("?")
        return ERR unless Checksum.valid?(digits)

        nil
      end

      # Formats a policy number line with optional error suffix.
      #
      # @param digits [String] the 9-character digit string
      #   Example: "123456789", "1?3456789"
      # @param error [String, nil] error code or nil
      #   Example: nil, "ILL", "ERR", "AMB"
      # @return [String] formatted output line
      #   Example: "123456789", "1?3456789 ILL", "123456789 ERR"
      def format_line(digits, error)
        error ? "#{digits} #{error}" : digits
      end
    end
  end
end
