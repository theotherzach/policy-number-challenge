# frozen_string_literal: true

require_relative "checksum"

module PolicyOcr
  module Entry
    class << self
      def call(entry)
        num_blocks = build_blocks(entry)
        digits = resolve_digits(num_blocks)

        if digits.include?("?")
          "#{digits} ILL"
        elsif Checksum.valid?(digits)
          digits
        else
          "#{digits} ERR"
        end
      end

      private

      def build_blocks(entry)
        num_blocks = []

        entry.each do |row|
          row.chars.each_slice(3).with_index do |(*chars), i|
            num_blocks[i] ||= { block: [], resolution: "" }
            num_blocks[i][:block] << chars
          end
        end

        num_blocks
      end

      def resolve_digits(num_blocks)
        num_blocks.each do |nb|
          nb[:resolution] = digit_map[nb[:block]]
        end
        num_blocks.map { |b| b[:resolution] }.join
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
