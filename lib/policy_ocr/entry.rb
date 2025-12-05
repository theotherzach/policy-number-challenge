# frozen_string_literal: true

require_relative "checksum"

module PolicyOcr
  module Entry
    class << self
      def call(entry)
        num_blocks = build_blocks(entry)
        digits = resolve_digits(num_blocks)
        error = error_for(digits)
        return format_line(digits, error) if error.nil?

        attempt_correction(num_blocks, digits, error)
      end

      private

      def attempt_correction(num_blocks, orig_digits, orig_error)
        candidates = make_candidates(num_blocks, orig_digits)

        case candidates.size
        when 0
          format_line(orig_digits, orig_error)
        when 1
          format_line(candidates.first, nil)
        else
          format_line(orig_digits, "AMB")
        end
      end

      def make_candidates(num_blocks, orig_digits)
        candidates = Set.new

        num_blocks.each_with_index do |num_block, index|
          block = num_block.fetch(:block)
          next if bad_char_elsewhere?(block, index)

          collect_candidates(candidates, block, orig_digits, index)
        end

        candidates
      end

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

              break if candidates.size > 1
            end
          end
        end
      end

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

      # at index 1 "0 ?0000000".include?("?") return true, digits cannot be fixed
      # at index 2 "00 0000000".include?("?") return false, we can attempt to fix
      def bad_char_elsewhere?(digits, index)
        digits.dup.tap { |og| og.slice!(index) }.include?("?")
      end

      def safe_make_digit(block, replacement, row_index, char_index)
        original = block.fetch(row_index).fetch(char_index)
        block[row_index][char_index] = replacement
        new_digit = digit_map[block]
        block[row_index][char_index] = original
        new_digit
      end

      def build_digit(orig_digits, new_digit, index)
        digits_array = orig_digits.chars
        digits_array[index] = new_digit
        digits_array.join
      end

      def build_blocks(entry)
        num_blocks = []

        entry.each do |row|
          row.chars.each_slice(3).with_index do |(*a), i|
            num_blocks[i] ||= { block: [], char: "" }
            num_blocks[i][:block] << a
          end
        end

        num_blocks.each do |nb|
          nb[:char] = digit_map[nb[:block]]
        end

        num_blocks
      end

      def resolve_digits(num_blocks)
        num_blocks.map { |b| b[:char] }.join
      end

      def error_for(digits)
        return "ILL" if digits.include?("?")
        return "ERR" unless Checksum.valid?(digits)

        nil
      end

      def format_line(digits, error)
        error ? "#{digits} #{error}" : digits
      end

      # rubocop:disable Metrics/AbcSize
      def digit_map
        @digit_map ||= Hash.new("?").merge(
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
        )
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
