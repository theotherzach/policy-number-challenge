# frozen_string_literal: true

module PolicyOcr
  class MalformedFile < StandardError; end

  class << self
    def fail(message, error_class = MalformedFile)
      raise error_class, message
    end

    def call(filename)
      validate_filename(filename)

      entry = Array.new(3)

      File.foreach(filename).with_index do |line, index|
        handle_line(entry, line.chomp! || line, index)
      end

      finalize_entry(entry)
    end

    def handle_line(entry, line_body, index)
      group_index = index % 4

      if group_index < 3
        validate_row(line_body, index)
        entry[group_index] = line_body
        nil
      else
        validate_separator(line_body, index)
        num_blocks = create_num_blocks(entry)
        entry.fill(nil)
        num_blocks
      end
    end

    def finalize_entry(entry)
      return if entry.compact.empty?
      fail("File ended without enough lines for a full entry (expected 3 data lines)") unless entry.all?

      create_num_blocks(entry)
    end

    def create_num_blocks(entry)
      num_blocks = []
      entry.each do |row|
        row.chars.each_slice(3).with_index do |(*a), i|
          num_blocks[i] ||= { block: [], resolution: "" }
          num_blocks[i][:block].push(a)
        end
      end
      num_blocks.each { |nb| resolve_num_block(nb) }
      puts num_blocks.map { |e| e.fetch(:resolution) }.join
      num_blocks
    end

    def resolve_num_block(num_block)
      num_block[:resolution] = digit_map[num_block.fetch(:block)]
      num_block
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
      ).freeze
    end
    # rubocop:enable Metrics/AbcSize

    private

    def validate_filename(filename)
      fail("No input file provided") if filename.nil? || filename.strip.empty?
    end

    def validate_row(line_body, index)
      if line_body.length != 27
        fail("Line #{index + 1}: expected 27 characters, got #{line_body.length}")
      elsif !line_body.match?(/\A[ _|]+\z/)
        fail("Line #{index + 1}: invalid characters; only space, '|' and '_' allowed")
      end
    end

    def validate_separator(line_body, index)
      return if line_body.empty? || line_body.match?(/\A *\z/)

      fail("Line #{index + 1}: expected a blank separator line")
    end
  end
end
