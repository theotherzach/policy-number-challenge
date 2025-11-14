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

      File.foreach(filename).with_index do |line, i|
        line_body = line.chomp! || line
        group_index = i % 4

        if group_index < 3
          validate_row(line_body, i)
          entry[group_index] = line_body
        else
          validate_separator(line_body, i)
          create_num_blocks(entry) # prints placeholders (current behavior)
          entry.fill(nil)
        end
      end

      # No trailing separator required:
      # - If we have a complete final entry (3 data lines), emit it.
      # - If we have 1–2 lines buffered, that's malformed.
      return unless entry.compact.any?
      fail("File ended without enough lines for a full entry (expected 3 data lines)") unless entry.all?

      create_num_blocks(entry)
    end

    def create_num_blocks(entry)
      num_blocks = []
      entry.each do |row|
        row.chars.each_slice(3).with_index do |(*a), i|
          num_blocks[i] ||= { block: [], resolution: "?" }
          num_blocks[i][:block].push(a)
        end
      end
      num_blocks.each { |num_block| resolve_num_block(num_block) }
      puts num_blocks.map { |e| e.fetch(:resolution) }.join
      num_blocks
    end

    def resolve_num_block(num_block)
      num_block[:resolution] = recognize_block(num_block.fetch(:block))
      num_block
    end

    def recognize_block(block)
      one = [
        [" ", " ", " "],
        [" ", " ", "|"],
        [" ", " ", "|"]
      ]
      return "1" if block == one

      "?"
    end

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
